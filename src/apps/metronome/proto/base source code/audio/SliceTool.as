/**
 * As seen here: http://labs.makemachine.net/?s=slice+tool
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
	
	[SWF( backgroundColor="0x222222", width="620", height="235", frameRate="60" )]
	public class SliceTool extends Sprite
	{
		public static const BUFFER_SIZE		:int = 8192;
		public static const SAMPLE_RATE		:int = 44100;
		public static const MILS_PER_SEC	:int = 1000;
		public static const PADDING			:int = 5;
		public static const WIDTH			:int = 610;
		public static const RENDERER_HEIGHT	:int = 150;
		public static const SCRUBBER_HEIGHT	:int = 35;
		
		// -- audio
		protected var _path			:String;
		protected var _insound		:Sound;
		protected var _outsound		:Sound;
		protected var _channel		:SoundChannel;
		protected var _samples		:int;
		protected var _xpos			:Number;
		protected var _lineLength	:Number;
		protected var _position		:int;
		protected var _detail		:int;
		protected var _outsample	:int;
		protected var _playing		:Boolean;
		protected var _playprev		:Boolean;
		protected var _loopflag		:Boolean;
		
		// -- display
		protected var _renderer		:Sprite;
		protected var _scrubber		:Sprite;
		protected var _overlay		:Sprite;
		protected var _init			:Boolean;
		protected var _left			:Sprite;
		protected var _right		:Sprite;
		protected var _grip			:Sprite;
		protected var _progress		:Sprite;
		protected var _playbutton	:PushButton;
		protected var _slider		:HUISlider;
		protected var _label		:Label;
		protected var _progressbar	:ProgressBar;
		
		public function SliceTool()
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
				_path = 'flying_lotus_sample.mp3';
			}
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.quality = StageQuality.LOW;
			
			_label = new Label( this, 270, 100, 'LOADING AUDIO' );
			_progressbar = new ProgressBar( this, 270, 120  );
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
			_outsample =_samples = _insound.length / MILS_PER_SEC * SAMPLE_RATE;
			
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
			var r:Graphics = _renderer.graphics;
			var s:Graphics = _scrubber.graphics;
			
			if( _xpos == 0 )
			{
				r.moveTo( PADDING, PADDING + RENDERER_HEIGHT * .5 );
				r.lineStyle( 1, 0xf05151, 1, true, LineScaleMode.NONE );
				
				if( !_init ) {
					s.moveTo( PADDING, PADDING * 2 + RENDERER_HEIGHT + ( SCRUBBER_HEIGHT * .5 ) )
					s.lineStyle( 1, 0xFFFFFF, 1, true, LineScaleMode.NONE );
				}
			}
			
			// -- draw waveforms
			var n:Number;
			var bytes:ByteArray = new ByteArray();
			var length:int = _position + BUFFER_SIZE < _outsample ? BUFFER_SIZE  : _outsample - _position;
			
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
					r.lineTo( PADDING + _xpos, 
						( PADDING * 2 + RENDERER_HEIGHT * .5 ) + n * RENDERER_HEIGHT * .5 );
					
					
					if( !_init ) {
						s.lineTo( PADDING + _xpos, 
							( ( PADDING * 2 ) + RENDERER_HEIGHT + 
								( SCRUBBER_HEIGHT * .5 ) ) + n * SCRUBBER_HEIGHT * .5 );
					}
					
					_xpos += _lineLength;
				}
				
				// -- increment the position
				_position ++;
			}
			
			if( _position == _outsample ) {
				onRenderWaveformComplete();
				return;	
			}
		}
		
		// -- initializes variables before render, disable the view
		protected function updateRenderer():void
		{
			_xpos = 0;
			_renderer.graphics.clear();
			_position = map( _left.x, PADDING, WIDTH + PADDING, 0, _samples );
			_outsample = map( _right.x, PADDING, WIDTH + PADDING, 0, _samples );
			_lineLength = WIDTH / ( (_outsample - _position ) / _detail );
			
			mouseChildren = false;
			addEventListener( Event.ENTER_FRAME, onRenderWaveform );
		}
		
		// -- once the render is done check to see if playing 
		// -- before render started and reset position and ousample and start playback
		protected function onRenderWaveformComplete():void
		{
			_init = true;
			
			_position = map( _left.x, PADDING, WIDTH + PADDING, 0, _samples );
			_outsample = map( _right.x, PADDING, WIDTH + PADDING, 0, _samples );
			
			if( _playprev ) {
				play();
				_playprev = false;
			}
			
			removeEventListener( Event.ENTER_FRAME, onRenderWaveform );
			
			mouseChildren = true;
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
				_playprev = false;
			}else {
				play();
				_playprev = true;
			}
		}
		
		protected function stop():void
		{
			if( _channel && _playing ) 
			{
				_progress.scaleX = 0;
				_playing = _loopflag = false;
				_playbutton.label = 'Play';
				_playbutton.selected = false;
				removeEventListener( Event.ENTER_FRAME, onPlayProgress );
				
				_channel.stop();
				_channel.removeEventListener( Event.SOUND_COMPLETE, onSoundComplete );
				_channel = null;
			}
		}
		
		protected function play():void
		{
			_loopflag = false;
			_playing = _playprev = true;
			_playbutton.label = 'Stop';
			_playbutton.selected = true;
			_outsound.addEventListener( SampleDataEvent.SAMPLE_DATA, onSampleData );
			_channel = _outsound.play();
			_channel.addEventListener( Event.SOUND_COMPLETE, onSoundComplete );
			addEventListener( Event.ENTER_FRAME, onPlayProgress );
		}
		
		// -- keep filling the buffer with data
		protected function onSampleData( event:SampleDataEvent ):void
		{
			var bytes:ByteArray = new ByteArray();
			var length:int = BUFFER_SIZE;
			
			if( _loopflag ) return;
			
			if( _position + event.position + BUFFER_SIZE > _outsample ) {
				length =  _outsample - ( _position + event.position );
				
				_loopflag = true;
			}
			
			_insound.extract( bytes, length, _position + event.position );
			
			event.data.writeBytes( bytes );
		}
		
		// -- starts audio as soon as it's ended
		protected function onSoundComplete( event:Event ):void {
			play();
		}
		
		protected function onPlayProgress( event:Event ):void
		{
			var position:int = ( _channel.position / MILS_PER_SEC * SAMPLE_RATE );
			var total:int = _outsample - _position;
			
			_progress.scaleX = position / total;
		}
		
		// ----------------------------------------------
		//
		// 	-- grip mouse / move handlers
		//
		// ----------------------------------------------
		protected function onGripMove( event:Event ):void
		{
			// -- constrain the grip positions
			if( _grip == _left ) {
				_grip.x = Math.max( PADDING, stage.mouseX );
				_grip.x = Math.min( _grip.x, _right.x - 10 );
			} 
			
			if( _grip == _right ) {
				_grip.x = Math.max( _left.x + 10, stage.mouseX );
				_grip.x = Math.min( _grip.x, PADDING + WIDTH);
			}
			
			// -- redraw and position the overlay
			drawRect( _overlay, 0, 0, Math.abs( _right.x - _left.x ), SCRUBBER_HEIGHT, 0x34d0d9, 1 );
			_overlay.x = _left.x;
		}
		
		protected function onGripMouseOver( event:MouseEvent ):void
		{
			if( event.target is Sprite ) 
			{
				var sprite:Sprite = event.target as Sprite;
				drawGrip( sprite, 0x00FF00 );
			}
		}
		
		protected function onGripMouseOut( event:MouseEvent ):void
		{
			if( event.target is Sprite ) 
			{
				var sprite:Sprite = event.target as Sprite;
				drawGrip( sprite, 0xf05151 );
			}
		}
		
		protected function onGripMouseDown( event:MouseEvent ):void 
		{
			if( event.target is Sprite ) 
			{
				stop();
				
				_grip = event.target as Sprite;
				drawGrip( _grip, 0xFFCC00 );
				
				stage.addEventListener( MouseEvent.MOUSE_UP, onGripMoveComplete );
				addEventListener( Event.ENTER_FRAME, onGripMove );
				_grip.removeEventListener( MouseEvent.MOUSE_OUT, onGripMouseOut );
				_grip.removeEventListener( MouseEvent.MOUSE_OVER, onGripMouseOver );
			}
		}
		
		protected function onGripMoveComplete( event:MouseEvent ):void
		{	
			removeEventListener( Event.ENTER_FRAME, onGripMove );
			stage.removeEventListener( MouseEvent.MOUSE_UP, onGripMoveComplete );
			_grip.addEventListener( MouseEvent.MOUSE_OUT, onGripMouseOut );
			_grip.addEventListener( MouseEvent.MOUSE_OVER, onGripMouseOver );
			drawGrip( _grip, 0xf05151 );
			_grip = null;
			
			updateRenderer();
		}
		
		// ----------------------------------------------
		//
		// 	-- scrubber mouse / move handlers
		//
		// ----------------------------------------------
		
		protected function onScrubberMouseDown( event:Event ):void
		{
			stop();
			addEventListener( Event.ENTER_FRAME, onScrubberMove );
			stage.addEventListener( MouseEvent.MOUSE_UP, onScrubberMoveComplete );
		}
		
		protected function onScrubberMove( event:Event ):void
		{
			var halfw:Number = _overlay.width * .5;
			_overlay.x = Math.max( PADDING, stage.mouseX - halfw );
			_overlay.x = Math.min( PADDING + WIDTH - _overlay.width, _overlay.x );
			_left.x = _overlay.x;
			_right.x = _overlay.x + _overlay.width;
		}
		
		protected function onScrubberMoveComplete( event:Event ):void
		{
			updateRenderer();
			stage.removeEventListener( MouseEvent.MOUSE_UP, onScrubberMoveComplete );
			removeEventListener( Event.ENTER_FRAME, onScrubberMove );
		}
		
		// ----------------------------------------------
		//
		// 	-- slider
		//
		// ----------------------------------------------
		
		protected function onSlider( event:Event ):void
		{
			stop();
			_detail = _slider.value;
			updateRenderer();
		}
		
		// ----------------------------------------------
		//
		// 	-- keyboard
		//
		// ----------------------------------------------
		
		protected function onKeyDown( event:KeyboardEvent ):void
		{
			switch( event.keyCode ) 
			{
				case 32:
					toggle();
					break;	
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
			
			// -- draw background shapes
			drawRect( this, PADDING, PADDING, WIDTH, RENDERER_HEIGHT, 0xFFFFFF, .15, false );
			drawRect( this, PADDING, PADDING * 2 + RENDERER_HEIGHT, WIDTH, SCRUBBER_HEIGHT, 0xFFFFFF, .15, false );
			
			// -- upper waveform renders selection
			_renderer 		= new Sprite();
			_renderer.filters = [ new GlowFilter( 0xf05151, 1, 6, 6, 1 ) ];
			
			// -- lower waveform renders entire wave
			_scrubber 		= new Sprite();
			_scrubber.filters = [ new GlowFilter( 0x34d0d9, 1, 3, 3, 1 ) ];
			
			// -- represents the area of the sound being viewed
			_overlay 	= new Sprite();
			_overlay.x  = PADDING;
			_overlay.y  = PADDING * 2 + RENDERER_HEIGHT;
			_overlay.blendMode = BlendMode.ADD;
			_overlay.alpha = .5;
			drawRect( _overlay, 0, 0, WIDTH, SCRUBBER_HEIGHT, 0x34d0d9, 1 );
			
			// -- draggable in point
			_left = new Sprite();
			_left.x = PADDING;
			_left.y = _overlay.y;
			drawGrip( _left, 0xf05151 );
			
			// -- draggable out point
			_right = new Sprite();
			_right.x = PADDING + WIDTH;
			_right.y = _overlay.y;
			drawGrip( _right, 0xf05151 );
			
			_progress = new Sprite();
			_progress.x = _progress.y = PADDING;
			_progress.scaleX = 0;
			_progress.blendMode = BlendMode.ADD;
			drawRect( _progress, 0, 0, WIDTH, RENDERER_HEIGHT, 0xFFFFFF, .1 );
			
			_playbutton = new PushButton( this, 515, PADDING * 4 + RENDERER_HEIGHT + SCRUBBER_HEIGHT, 'Play', toggle );
			_playbutton.toggle = true;
			
			_slider = new HUISlider( this, 0, 0, 'Waveform Detail', onSlider );
			_slider.minimum = 1;
			_slider.maximum = 500;
			_slider.value = 1;
			_slider.x = PADDING;
			_slider.y =  PADDING * 5 + RENDERER_HEIGHT + SCRUBBER_HEIGHT;
			_slider.width = 400;
			_slider.labelPrecision = 0;
			
			// -- add to stage
			addChild( _renderer );
			addChild( _scrubber );
			addChild( _overlay );
			addChild( _left );
			addChild( _right );
			addChild( _progress );
			
			// -- add listeners
			stage.addEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
			
			_left.addEventListener( MouseEvent.MOUSE_OVER, onGripMouseOver );
			_left.addEventListener( MouseEvent.MOUSE_DOWN, onGripMouseDown );
			_left.addEventListener( MouseEvent.MOUSE_OUT, onGripMouseOut );
			
			_right.addEventListener( MouseEvent.MOUSE_OVER, onGripMouseOver );
			_right.addEventListener( MouseEvent.MOUSE_DOWN, onGripMouseDown );
			_right.addEventListener( MouseEvent.MOUSE_OUT, onGripMouseOut );
			
			_renderer.addEventListener( MouseEvent.MOUSE_DOWN, toggle );
			
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
		
		protected function drawGrip( grip:Sprite, color:uint ):void
		{
			drawRect( grip, -4, 0, 10, SCRUBBER_HEIGHT, 0xFFCC00, 0 );
			drawRect( grip, grip == _left ? 0 : -4, -5, 5, 5, color, 1, false );
			drawRect( grip, 0, 0, 1, SCRUBBER_HEIGHT, color, 1, false );
			drawRect( grip, grip == _left ? 0 : -4, SCRUBBER_HEIGHT, 5, 5, color, 1, false );
		}
		
		// ----------------------------------------------
		//
		// 	-- utils
		//
		// ----------------------------------------------
		
		protected function normalize(value:Number, min:Number, max:Number):Number {
			return (value - min) / (max - min);
		}
		
		protected function interpolate(normValue:Number, min:Number, max:Number):Number {
			return min + (max - min) * normValue;
		}
		
		protected function map(value:Number, min1:Number, max1:Number, min2:Number, max2:Number):Number {
			return interpolate( normalize(value, min1, max1), min2, max2);
		}
	}
}

