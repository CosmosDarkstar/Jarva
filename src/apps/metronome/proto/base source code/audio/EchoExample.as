/**
 * As seen here: http://labs.makemachine.net/2010/07/echo/
 */
package makemachine.audio
{
	import com.bit101.components.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.media.*;
	import flash.net.*;
	import flash.utils.*;
	
	[SWF( backgroundColor="0x222222", width="620", height="100", frameRate="60" )]
	public class EchoExample extends Sprite
	{
		// -- constants
		public static const BUFFER_SIZE		:int = 8192;
		public static const SAMPLE_RATE		:int = 44100;
		public static const MILS_PER_SEC	:int = 1000;
		public static const PADDING			:int = 5;
		public static const WIDTH			:int = 610;
		public static const DLY_BUFFER_SIZE	:int = BUFFER_SIZE * 16;
		public static const TEMPO			:int = 160;
		
		// -- sound
		protected var _path			:String;
		protected var _insound		:Sound;
		protected var _outsound		:Sound;
		protected var _channel		:SoundChannel;
		protected var _position		:int;
		protected var _playing		:Boolean;
		protected var _samples		:int;
		protected var _bufferindex	:int;
		protected var _delaytime	:int; 
		protected var _delaybuffer	:Vector.<Number>;
		
		// -- display
		protected var _label		:Label;
		protected var _progressbar	:ProgressBar;
		protected var _delayknob	:Knob;
		protected var _feedbackknob	:Knob;
		protected var _mixknob		:Knob;
		protected var _playbutton	:PushButton;
		protected var _visualizer	:Sprite;
		
		// -- sync btns
		protected var _syncbtns				:Array;
		protected var _selectedsync			:String;
		public static const SYNC_OPTIONS	:Array = [ 'Off', '1', '2', '4', '8', '16' ];
		
		public function EchoExample()
		{
			addEventListener( Event.ENTER_FRAME, onAdded );
		}
		
		protected function onAdded( event:Event ):void
		{
			if( !stage ) return;
			if( !stage.stageWidth ) return;
			
			var o:Object = stage.root.loaderInfo.parameters;
			
			if( o['path'] ){
				_path = o['path'];
			} else {
				_path = '160_bpm_echo_beat.mp3';
			}
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			_label = new Label( this, 270, 25, 'LOADING AUDIO' );
			_progressbar = new ProgressBar( this, 270, 45  );
			_progressbar.width = _label.width;
			
			loadAudio();
			
			removeEventListener( Event.ENTER_FRAME, onAdded );
		}
		
		// ----------------------------------------------
		//
		// 	-- loading
		//
		// ----------------------------------------------
		
		protected function loadAudio():void
		{
			_insound = new Sound();
			_insound.addEventListener( Event.COMPLETE, onLoadComplete );
			_insound.addEventListener( ProgressEvent.PROGRESS, onLoadProgress );
			_insound.load( new URLRequest( _path ) );
			
			_outsound = new Sound();
		}
		
		protected function onLoadProgress( event:ProgressEvent ):void {
			_progressbar.value = event.bytesLoaded / event.bytesTotal;
		}
		
		// -- create the delay buffer
		// -- a very long vector filled with zeros
		protected function onLoadComplete( event:Event ):void
		{
			createDisplay();
			
			_position = 0;
			_bufferindex = 0;
			_delaytime = 4096;
			
			_delaybuffer = new Vector.<Number>( DLY_BUFFER_SIZE );
			for( var i:int = 0; i < DLY_BUFFER_SIZE; i++ ) {
				_delaybuffer[i] = 0;
			}
			
			// -- hacking this by removing some from the total count
			// -- this corrects poor mp3 looping because of meta-data at the beginning of the file
			_samples = _insound.length / MILS_PER_SEC * SAMPLE_RATE - 3500;
			
			_insound.removeEventListener( Event.COMPLETE, onLoadComplete );
			_insound.removeEventListener( ProgressEvent.PROGRESS, onLoadProgress );
		}
		
		// ----------------------------------------------
		//
		// 	-- sound
		//
		// ----------------------------------------------
		
		protected function toggle( event:Event = null ):void
		{
			if( _playing ) {
				stop();
			}else {
				play();
			}
		}
		
		// -- stop audio, stop visualizer, reset u.i.
		protected function stop():void
		{
			if( _channel && _playing ) 
			{
				_playing = false;
				_playbutton.label = 'Play';
				_playbutton.selected = false;
				_channel.stop();
				_channel = null;
				removeEventListener( Event.ENTER_FRAME, onEnterFrame );
			}
		}
		
		// -- reset u.i., start audio, start visualizer
		protected function play():void
		{
			_position = 0;
			_playing  = true;
			_playbutton.label = 'Stop';
			_playbutton.selected = true;
			_outsound.addEventListener( SampleDataEvent.SAMPLE_DATA, onSampleData );
			_channel = _outsound.play();
			addEventListener( Event.ENTER_FRAME, onEnterFrame );
		}
		
		// -- keep filling the buffer with data
		// -- no need for sound complete here, we use the length variable as the increment for position
		// -- creates seamless loop
		protected function onSampleData( event:SampleDataEvent ):void
		{
			var bytes:ByteArray = new ByteArray();
			var length:int = _position + BUFFER_SIZE > _samples ?  _samples - _position : BUFFER_SIZE;
			
			_insound.extract( bytes, length, _position );
			_position = _position + length >= _samples ? 0 : _position + length;
			
			event.data.writeBytes( createDelay( bytes ) );
		}
		
		// -- runs through every sample in the current buffer
		// -- caches each sample in the delay buffer
		// -- reads cached samples n( getDelayTime ) indices away from bufferindex 
		// -- merges them w/ current sample output
		public function createDelay( samples:ByteArray ):ByteArray
		{
			var bytes:ByteArray = new ByteArray();
			
			var output	:Number;
			var write	:Number;
			var history	:Number;
			var index	:Number;
			var delay	:int = getDelayTime();
			var feedback:Number = ( _feedbackknob.value / 10 ) - .1;
			var mix		:Number = _mixknob.value / 10;
			
			samples.position = 0;
			
			while( samples.bytesAvailable )
			{
				// -- current sample
				output = samples.readFloat();
				
				// -- write the current sample into memory
				_delaybuffer[ _bufferindex ] = output;
				
				// -- set the index to from which to get history sample
				index = _bufferindex - delay;
				if( index < 0 ) {
					index += DLY_BUFFER_SIZE;
				}
				
				// -- merget output w/ history
				history = _delaybuffer[ index ];
				output = history * mix + output * ( 1 - mix );
				
				// -- add current history sample & multiply by feedback 
				// -- overtime this value will resolve to zero if nothing else is written to this index
				_delaybuffer[ _bufferindex ] += history * feedback;
				
				bytes.writeFloat( output );
				
				if( ++_bufferindex == DLY_BUFFER_SIZE )
					_bufferindex = 0;
			}
			
			bytes.position = 0;
			return bytes;
		}
		
		// -- not very pretty but gets the point across
		// -- if there are 44100 samples in a second 
		// -- multiply that by 60 as in 60 seconds per minute
		// -- this gives us the number of samples in a minute
		// -- dividing this number by TEMPO gives us the duration of each beat in samples
		// -- we can then multiply or divide to get whole, half, quater, eighth, & sixteenth notes
		protected function getDelayTime():int 
		{
			var delay:int;
			var noteDuration:Number = SAMPLE_RATE * 60 / TEMPO;
			switch( _selectedsync ) 
			{
				case 'Off':
					delay = _delayknob.value / MILS_PER_SEC * SAMPLE_RATE;
					break;
				case '1':
					delay = noteDuration * 4
					break;
				
				case '2':
					delay = noteDuration * 2;
					break;
				
				case '4':
					delay = noteDuration;
					break;
				
				case '8':
					delay = noteDuration * .5;
					break;
				
				case '16':
					delay = noteDuration * .25;
					break;
				
				default:
					delay = _delayknob.value / 1000 * SAMPLE_RATE;
					break;
			}
			
			return delay;
		}
		
		// ----------------------------------------------
		//
		// 	-- sync options
		//
		// ----------------------------------------------
		protected function onSyncButtonDown( event:MouseEvent ):void
		{
			if( event.target is PushButton ) 
			{
				var btn:PushButton;
				var targ:PushButton = event.target as PushButton;
				for each( btn in _syncbtns ) 
				{
					if( btn == targ ) 
					{
						btn.selected = true;
						_selectedsync = btn.label;
					} else {
						btn.selected = false;
					}
				}
				
				_delayknob.mouseEnabled = _delayknob.mouseChildren = _selectedsync == 'Off';
				_delayknob.alpha = _selectedsync == 'Off' ? 1 : .3;
			}
		}
		
		// ----------------------------------------------
		//
		// 	-- visualizer
		//
		// ----------------------------------------------
		
		// -- draws a simple visualizer
		protected function onEnterFrame( event:Event ):void
		{
			var bytes:ByteArray = new ByteArray();
			
			if( !SoundMixer.areSoundsInaccessible() ) 
			{
				_visualizer.graphics.clear();
				_visualizer.graphics.lineStyle( 1, 0xf05151, 1, true );
				_visualizer.graphics.drawRect( 0, 0, 190, 65 );
				_visualizer.graphics.moveTo( 0, 32 );
				
				SoundMixer.computeSpectrum( bytes );
				bytes.position = 0;
				
				if( bytes.bytesAvailable ) 
				{
					var i:int;
					var n:Number;
					
					for( i = 0; i < 256; i++ ) 
					{
						n = Math.min( bytes.readFloat(), 1 );
						n = Math.max( n, -1 );
						_visualizer.graphics.lineTo( ( 190 / 256 ) * i, 32 + n * 32);
					}
				}
			}
		}
		
		
		// ----------------------------------------------
		//
		// 	-- graphics
		//
		// ----------------------------------------------
		
		protected function createDisplay():void
		{
			_label.visible = _progressbar.visible = false;
			
			drawRect( this, PADDING, PADDING, 185, 90 );
			drawRect( this, 195, PADDING, 225, 90, 0xFFFFFF, .15, false );
			
			_playbutton = new PushButton( this, 425, 75, 'Play', toggle );
			_playbutton.toggle = true;
			_playbutton.width = 190
			
			var hbox:HBox = new HBox( this, PADDING * 4, PADDING * 2 );
			hbox.spacing = 20;
			
			_delayknob = new Knob( hbox, 0, 0, 'Delay (ms)' );
			_delayknob.minimum = 1;
			_delayknob.maximum = 1000;
			_delayknob.value = 20;
			_delayknob.labelPrecision = 0;
			_delayknob.draw();
			
			_feedbackknob = new Knob( hbox, 0, 0, 'Feedback' );
			_feedbackknob.minimum = 0;
			_feedbackknob.maximum = 10;
			_feedbackknob.value = 9;
			_feedbackknob.draw();
			
			_mixknob = new Knob( hbox, 0,  0, 'Mix' );
			_mixknob.minimum = 0;
			_mixknob.maximum = 10;
			_mixknob.value = 5;
			_mixknob.draw();
			
			var btn:PushButton;
			var label:Label = new Label( this, 200, 20, 'BPM Sync' );
			
			hbox = new HBox( this, 205, 40 );
			_syncbtns = [];
			_selectedsync = 'Off';
			var i:int;
			for( i = 0; i < SYNC_OPTIONS.length; i++ ) 
			{
				btn = new PushButton( hbox, 0, 0, SYNC_OPTIONS[i], onSyncButtonDown );
				btn.toggle = true;
				btn.selected = i == 0;
				btn.width = 30;
				_syncbtns.push( btn );
			}
			
			_visualizer = new Sprite();
			_visualizer.x = 425;
			_visualizer.y = PADDING;
			
			_visualizer.graphics.lineStyle( 1, 0xf05151, 1, true );
			_visualizer.graphics.drawRect( 0, 0, 190, 65 );
			_visualizer.graphics.moveTo( 0, 32 );
			_visualizer.graphics.lineTo( 190, 32 );
			
			addChild( _visualizer );
		}
		
		// -- draws boxes in bg
		protected function drawRect( sprite:Sprite, 
									 xpos:int, ypos:int, 
									 w:int, h:int, color:uint = 0xFFFFFF, 
									 a:Number = .15, clear:Boolean = true ):void {
			clear ? 
				sprite.graphics.clear() :
				null;
			sprite.graphics.beginFill( color, a );
			sprite.graphics.drawRect( xpos, ypos, w, h );
			sprite.graphics.endFill();
		}
		
	}
}