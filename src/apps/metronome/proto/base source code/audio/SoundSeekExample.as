/**
 * As seen here: http://labs.makemachine.net/2010/07/seeking-and-timecode-w-dynamic-audio/
 */
package makemachine.audio
{
	import com.bit101.components.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.filters.GlowFilter;
	import flash.media.*;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	[SWF( backgroundColor="0x222222", width="620", height="80", frameRate="60" )]
	public class SoundSeekExample extends Sprite
	{
		public static const BUFFER_SIZE		:int = 8192;
		public static const SAMPLE_RATE		:int = 44100;
		public static const MILS_PER_SEC	:int = 1000;
		public static const PADDING			:int = 5;
		public static const WIDTH			:int = 610;
		public static const SCRUBBER_HEIGHT	:int = 35;
		
		// -- audio
		protected var _path			:String;
		protected var _insound		:Sound;
		protected var _outsound		:Sound;
		protected var _channel		:SoundChannel;
		protected var _samples		:uint;
		protected var _position		:uint;
		protected var _detail		:uint;
		protected var _playing		:Boolean;
		protected var _resume		:Boolean;
		protected var _startpos		:uint;
		
		// -- display
		protected var _scrubber		:Sprite;
		protected var _overlay		:Sprite;
		protected var _init			:Boolean;
		protected var _progress		:Sprite;
		protected var _playbutton	:PushButton;
		protected var _label		:Label;
		protected var _progressbar	:ProgressBar;
		protected var _xpos			:Number;
		protected var _lineLength	:Number;
		protected var _timelabel	:Label;
		protected var _samplelabel	:Label;
		
		public function SoundSeekExample()
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
				_path = '115_bpm_beat.mp3';
			}
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.quality = StageQuality.LOW;
			
			_label = new Label( this, 270, 20, 'LOADING AUDIO' );
			_progressbar = new ProgressBar( this, 270, 40 );
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
		
		protected function onLoadComplete( event:Event ):void
		{
			_detail = 10;
			_position = 0;
			_samples = _insound.length / MILS_PER_SEC * SAMPLE_RATE;
			
			createDisplay();
			updateRenderer();
			
			_insound.removeEventListener( Event.COMPLETE, onLoadComplete );
			_insound.removeEventListener( ProgressEvent.PROGRESS, onLoadProgress );
		}
		
		// ----------------------------------------------
		//
		// 	-- renderer
		//
		// ----------------------------------------------
		
		// -- this method draws the wave forms
		// -- if this is the first render it will draw the waveform at the bottom of the display
		protected function onRenderWaveform( even:Event ):void
		{
			// -- initialize the graphics
			var s:Graphics = _scrubber.graphics;
			
			if( _xpos == 0 )
			{
				s.moveTo( 0, ( SCRUBBER_HEIGHT * .5 ) )
				s.lineStyle( 1, 0xFFFFFF, 1, true, LineScaleMode.NONE );
			}
			
			// -- draw waveforms
			var n:Number;
			var bytes:ByteArray = new ByteArray();
			var length:int = _position + BUFFER_SIZE < _samples ? BUFFER_SIZE  : _samples - _position;
			
			_insound.extract( bytes, length, _position );
			bytes.position = 0;
			
			while( bytes.position < bytes.length )
			{
				// -- average left and right channles
				n = bytes.readFloat() + bytes.readFloat();
				n *= .5;
				
				// -- this modulus allows us to only draw every other nth sample
				if( _position % _detail == 0 )
				{
					
					s.lineTo( PADDING + _xpos, 
						(  ( SCRUBBER_HEIGHT * .5 ) ) + n * SCRUBBER_HEIGHT * .5 );
					_xpos += _lineLength;
				}
				
				// -- increment the position
				_position ++;
			}
			
			if( _position == _samples ) {
				onRenderWaveformComplete();
				return;	
			}
		}
		
		// -- initializes variables before render, disable the view
		protected function updateRenderer():void
		{
			_xpos = 0;
			_lineLength = (WIDTH - ( PADDING  ) ) / ( _samples / _detail );
			
			mouseChildren = false;
			addEventListener( Event.ENTER_FRAME, onRenderWaveform );
		}
		
		// -- once the render is done check to see if playing 
		// -- before render started and reset position and ousample and start playback
		protected function onRenderWaveformComplete():void
		{
			_init = true;
			_position = 0;
			mouseChildren = true;
			removeEventListener( Event.ENTER_FRAME, onRenderWaveform );
		}
		
		// ----------------------------------------------
		//
		// 	-- sound
		//
		// ----------------------------------------------
		// -- toggles between play and stop
		protected function toggle( event:Event = null ):void
		{
			if( _playing ) {
				stop();
			}else {
				play();
			}
		}
		
		protected function stop():void
		{
			if( _channel && _playing ) 
			{
				_progress.scaleX = 0;
				_playing = false;
				_playbutton.label = 'Play';
				_playbutton.selected = false;
				_startpos = 0;
				updateLabels( 0 );
				removeEventListener( Event.ENTER_FRAME, onPlayProgress );
				
				_channel.stop();
				_channel.removeEventListener( Event.SOUND_COMPLETE, onSoundComplete );
				_channel = null;
			}
		}
		
		protected function play():void
		{
			_playing = true;
			_playbutton.label = 'Stop';
			_playbutton.selected = true;
			_position = _startpos;
			_outsound.addEventListener( SampleDataEvent.SAMPLE_DATA, onSampleData );
			_channel = _outsound.play();
			_channel.addEventListener( Event.SOUND_COMPLETE, onSoundComplete );
			addEventListener( Event.ENTER_FRAME, onPlayProgress );
		}
		
		// -- keep filling the buffer with data
		protected function onSampleData( event:SampleDataEvent ):void
		{
			var bytes:ByteArray = new ByteArray();
			var length:int = _position + BUFFER_SIZE > _samples ?  _samples - _position : BUFFER_SIZE;
			
			_insound.extract( bytes, length, _position );
			event.data.writeBytes( bytes );
			
			_position += length;
		}
		
		// -- calls stop method as soon as there are no more samples to play
		protected function onSoundComplete( event:Event ):void {
			stop();
		}
		
		protected function onPlayProgress( event:Event ):void
		{
			var pos:int = ( _channel.position /  MILS_PER_SEC  * SAMPLE_RATE ) + _startpos;
			_progress.scaleX = pos / _samples;
			updateLabels( pos );
		}
		
		
		// ----------------------------------------------
		//
		// 	-- scrubber mouse / move handlers
		//
		// ----------------------------------------------
		
		protected function onScrubberMouseDown( event:Event ):void
		{
			_resume = _playing;
			stop();
			addEventListener( Event.ENTER_FRAME, onScrubberMove );
			stage.addEventListener( MouseEvent.MOUSE_UP, onScrubberMoveComplete );
		}
		
		protected function onScrubberMove( event:Event ):void
		{
			if( _scrubber.mouseX < 0 ) return;
			_progress.width = _scrubber.mouseX;
			_startpos = _samples * ( _scrubber.mouseX / _scrubber.width );
			_startpos = Math.min( _samples, _startpos );
			updateLabels(_startpos);
		}
		
		protected function updateLabels( value:Number ):void
		{
			_timelabel.text = 'Time: ' + 
							  Math.floor( value / SAMPLE_RATE ) + ':' + 
							  Math.round( value / ( SAMPLE_RATE / 1000 ) % 1000 );
			
			_samplelabel.text = 'Sample Position: ' + value;
		}
		
		protected function onScrubberMoveComplete( event:Event ):void
		{
			if( _resume ) {
				play();
			}
			stage.removeEventListener( MouseEvent.MOUSE_UP, onScrubberMoveComplete );
			removeEventListener( Event.ENTER_FRAME, onScrubberMove );
		}
		
		// ----------------------------------------------
		//
		// 	-- graphics
		//
		// ----------------------------------------------
		
		protected function createDisplay():void
		{
			_label.visible = _progressbar.visible = false;
			
			// -- draw background shapes
			drawRect( this, PADDING, PADDING * 2 + SCRUBBER_HEIGHT, WIDTH, 30, 0xFFFFFF, .15, false );
			
			// -- lower waveform renders entire wave
			_scrubber 		= new Sprite();
			_scrubber.filters = [ new GlowFilter( 0x34d0d9, 1, 3, 3, 1 ) ];
			_scrubber.x = _scrubber.y = PADDING;
			
			// -- represents the area of the sound being viewed
			_overlay 	= new Sprite();
			_overlay.x  = PADDING;
			_overlay.y  = PADDING;
			_overlay.blendMode = BlendMode.ADD;
			_overlay.alpha = .5;
			drawRect( _overlay, 0, 0, WIDTH, SCRUBBER_HEIGHT, 0x34d0d9, 1 );
			
			_progress = new Sprite();
			_progress.x = _progress.y = PADDING;
			_progress.scaleX = 0;
			_progress.blendMode = BlendMode.ADD;
			_progress.mouseEnabled = _progress.mouseChildren = false;
			drawRect( _progress, 0, 0, WIDTH, SCRUBBER_HEIGHT + PADDING, 0xFFFFFF, .1 );
			
			_timelabel = new Label( this, PADDING, PADDING * 3 + SCRUBBER_HEIGHT, 'Time: 0:00' );
			_samplelabel = new Label( this, 80, PADDING * 3 + SCRUBBER_HEIGHT, 'Sample Position: 0' );
			
			
			_playbutton = new PushButton( this, 510, PADDING * 3 + SCRUBBER_HEIGHT, 'Play', toggle );
			_playbutton.toggle = true;
			
			// -- add to stage
			addChild( _scrubber );
			addChild( _overlay );
			addChild( _progress );
			
			_overlay.addEventListener( MouseEvent.MOUSE_DOWN, onScrubberMouseDown );
		}
		
		// -- draws boxes in bg
		protected function drawRect( sprite:Sprite, 
									 xpos:int, ypos:int, 
									 w:int, h:int, color:uint = 0xFFFFFF, 
									 a:Number = .25, clear:Boolean = true ):void {
			clear ? 
				sprite.graphics.clear() :
				null;
			sprite.graphics.beginFill( color, a );
			sprite.graphics.drawRect( xpos, ypos, w, h );
			sprite.graphics.endFill();
		}
	}
}

