/**
 * As seen here: http://labs.makemachine.net/2010/08/tremelo/
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
	public class TremoloExample extends Sprite
	{
		// -- constants
		public static const BUFFER_SIZE		:int = 8192;
		public static const SAMPLE_RATE		:int = 44100;
		public static const MILS_PER_SEC	:int = 1000;
		public static const PADDING			:int = 5;
		public static const WIDTH			:int = 610;
		public static const TEMPO			:int = 240;
		
		// -- sound
		protected var _synthpath	:String;
		protected var _drumpath		:String;
		protected var _synth		:Sound;
		protected var _drums		:Sound;
		protected var _outsound		:Sound;
		protected var _channel		:SoundChannel;
		protected var _position		:int;
		protected var _playing		:Boolean;
		protected var _samples		:int;
		protected var _start		:int;
		protected var _trempos		:int;
		
		// -- display
		protected var _label		:Label;
		protected var _progressbar	:ProgressBar;
		protected var _depthKnob	:Knob;
		protected var _rateKnob		:Knob;
		protected var _playbutton	:PushButton;
		protected var _visualizer	:Sprite;
		protected var _drumvolKnob	:Knob;
		
		// -- sync btns
		protected var _syncbtns				:Array;
		protected var _selectedsync			:String;
		public static const SYNC_OPTIONS	:Array = [ 'Off', '1', '2', '4', '8', '16' ];
		
		public function TremoloExample()
		{
			addEventListener( Event.ENTER_FRAME, onAdded );
		}
		
		protected function onAdded( event:Event ):void
		{
			if( !stage ) return;
			if( !stage.stageWidth ) return;
			
			var o:Object = stage.root.loaderInfo.parameters;
			
			_synthpath = o['synth'] ? o['synth'] : 'synth.mp3';
			_drumpath = o['drums'] ? o['drums'] : 'drums.mp3';
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			_label = new Label( this, 270, 25, 'LOADING SYNTH' );
			_progressbar = new ProgressBar( this, 270, 45  );
			_progressbar.width = _label.width;
			
			loadSynth();
			
			removeEventListener( Event.ENTER_FRAME, onAdded );
		}
		
		// ----------------------------------------------
		//
		// 	-- loading
		//
		// ----------------------------------------------
		
		// -- load the synth
		protected function loadSynth():void
		{
			_synth = new Sound();
			_synth.addEventListener( Event.COMPLETE, onSynthLoadComplete );
			_synth.addEventListener( ProgressEvent.PROGRESS, onLoadProgress );
			_synth.load( new URLRequest( _synthpath ) );
		}
		
		// -- when the synth load is complete load the drums
		protected function onSynthLoadComplete( event:Event ):void
		{
			_label.text = 'LOADING BEAT';
			
			_drums = new Sound();
			_drums.addEventListener( Event.COMPLETE, onDrumsLoadComplete );
			_drums.addEventListener( ProgressEvent.PROGRESS, onLoadProgress );
			_drums.load( new URLRequest( _drumpath ) );
			
			_synth.removeEventListener( Event.COMPLETE, onSynthLoadComplete );
			_synth.removeEventListener(ProgressEvent.PROGRESS, onLoadProgress );
		}
		
		// -- display a progress bar
		protected function onLoadProgress( event:ProgressEvent ):void {
			_progressbar.value = event.bytesLoaded / event.bytesTotal;
		}
		
		// -- when the drums have loaded initialize vars and create the u.i.
		protected function onDrumsLoadComplete( event:Event ):void
		{
			_trempos = 0;
			_position = _start = 960;
			
			_samples = _synth.length / MILS_PER_SEC * SAMPLE_RATE - _start;
			
			_drums.removeEventListener( Event.COMPLETE, onSynthLoadComplete );
			_drums.removeEventListener(ProgressEvent.PROGRESS, onLoadProgress );
			
			_outsound = new Sound();
			
			createDisplay();
		}
		
		// ----------------------------------------------
		//
		// 	-- sound
		//
		// ----------------------------------------------
		
		// -- toggles play/stop
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
			_trempos = 0;
			_position = _start;
			_playing  = true;
			_playbutton.label = 'Stop';
			_playbutton.selected = true;
			_outsound.addEventListener( SampleDataEvent.SAMPLE_DATA, onSampleData );
			_channel = _outsound.play();
			addEventListener( Event.ENTER_FRAME, onEnterFrame );
		}
		
		// -- keep filling the buffer with data
		// -- process audio samples
		// -- create separate byte arrays for the synth and drums
		// -- process the synth track w/ tremlo and add the drums after processing
		// -- set volume of drum track based on drumvolKnob.value
		protected function onSampleData( event:SampleDataEvent ):void
		{
			var synthbytes:ByteArray = new ByteArray();
			var drumbytes:ByteArray = new ByteArray();
			
			var length:int = _position + BUFFER_SIZE > _samples ?  _samples - _position : BUFFER_SIZE;
			
			_synth.extract( synthbytes, length, _position );
			_drums.extract( drumbytes, length, _position );
			_position = _position + length >= _samples ? _start : _position + length;
			
			synthbytes.position = drumbytes.position = 0;
			
			var trem:Number;
			var rate:Number = getRateTime();
			var depth:Number = _depthKnob.value / _depthKnob.maximum;
			var drumvol:Number = _drumvolKnob.value / _drumvolKnob.maximum;
			
			for( var i:int = 0; i < length; i++ )
			{
				var l:Number = synthbytes.readFloat();
				var r:Number = synthbytes.readFloat();
				
				// -- creating an ocsillating value between 1 & 0
				trem = Math.sin( ( Math.PI * 2 ) * rate  * _trempos / SAMPLE_RATE );
				
				// -- using additive process here because we actually want to add the modulated audio to the existing 
				// -- audio, this way if the depth is zero the original audio is still audible
				// -- scale the amplitude of the sample by trem oscillation creates modulation
				l += l * trem * depth;
				r += r * trem * depth;
				
				// -- add the drum track and set the volume based on the drum vol knob
				l += drumbytes.readFloat() * drumvol;
				r += drumbytes.readFloat() * drumvol;
				
				event.data.writeFloat( l );
				event.data.writeFloat( r );
				
				_trempos++;
			}
		}
		
		// ----------------------------------------------
		//
		// 	-- visualizer
		//
		// ----------------------------------------------
		
		// -- draws a simple visualizer
		// -- only display 50 frequency bands because that is where most of the sound is happening
		protected function onEnterFrame( event:Event ):void
		{
			var xpos:int;
			var bytes:ByteArray = new ByteArray();
			
			if( !SoundMixer.areSoundsInaccessible() ) 
			{
				_visualizer.graphics.clear();
				_visualizer.graphics.lineStyle( 1, 0xf05151, 1, true );
				_visualizer.graphics.drawRect( 0, 0, 190, 65 );
				_visualizer.graphics.moveTo( 0, 32 );
				
				SoundMixer.computeSpectrum( bytes, true );
				bytes.position = 0;
				
				if( bytes.bytesAvailable ) 
				{
					var i:int;
					var n:Number;
					
					for( i = 0; i < 50; i++ ) 
					{
						xpos = ( 190 / 50 ) * i;
						n = Math.min( bytes.readFloat(), 1 );
						n = Math.max( n, -1 );
						_visualizer.graphics.moveTo( xpos, 64 );
						_visualizer.graphics.lineTo( xpos, 64 - ( n * 64 ) );
					}
					
					bytes.position = 0;
					for( i = 0; i < 50; i++ ) 
					{
						xpos = 190 - ( 190 / 50 ) * ( i );
						n = Math.min( bytes.readFloat(), 1 );
						n = Math.max( n, -1 );
						
						_visualizer.graphics.moveTo( xpos, 64 );
						_visualizer.graphics.lineTo( xpos, 64 - ( n * 64 ) );
					}
				}
			}
		}
		
		// -- not very pretty but gets the point across
		// -- returns the number of times one oscillation should occur each second
		protected function getRateTime():int 
		{
			var rate:int;
			var noteDuration:Number = 60 / TEMPO * 4;
			switch( _selectedsync ) 
			{
				case 'Off':
					rate = _rateKnob.value;
					break;
				case '1':
					rate = noteDuration;
					break;
				
				case '2':
					rate = noteDuration * 2;
					break;
				
				case '4':
					rate = noteDuration * 4;
					break;
				
				case '8':
					rate = noteDuration * 8;
					break;
				
				case '16':
					rate = noteDuration * 16;
					break;
				
				default:
					rate = _rateKnob.value;
					break;
			}
			
			return rate;
		}
		
		// ----------------------------------------------
		//
		// 	-- sync options
		//
		// ----------------------------------------------
		// -- enables bpm sync
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
				
				_rateKnob.mouseEnabled = _rateKnob.mouseChildren = _selectedsync == 'Off';
				_rateKnob.alpha = _selectedsync == 'Off' ? 1 : .3;
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
			
			_depthKnob = new Knob( hbox, 0, 0, 'Depth' );
			_depthKnob.minimum = 0;
			_depthKnob.maximum = 100;
			_depthKnob.value = 50;
			_depthKnob.labelPrecision = 0;
			_depthKnob.draw();
			
			_rateKnob = new Knob( hbox, 0, 0, 'Speed (per sec)' );
			_rateKnob.minimum = 1;
			_rateKnob.maximum = 10;
			_rateKnob.value = 2.5;
			_rateKnob.draw();
			
			_drumvolKnob = new Knob( hbox, 0, 0, 'Beat' );
			_drumvolKnob.minimum = 0;
			_drumvolKnob.maximum = 100;
			_drumvolKnob.value = 100;
			
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