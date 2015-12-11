/**
 * As seen here: http://labs.makemachine.net/2010/06/sine-square-waves/
 */
package makemachine.audio
{
	import com.bit101.components.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.media.*;
	import flash.utils.ByteArray;

	[SWF( backgroundColor="0x222222", width="620", height="145", frameRate="60" )]
	public class WaveformExample extends Sprite
	{
		public static const SAMPLE_RATE	:int = 44100;
		public static const BUFFER_SIZE	:int = 8192;
		public static const MAX_PITCH	:int = 1000;
		public static const MIN_PITCH	:int = 220;
		
		protected var _knob			:Knob;
		protected var _squareBox	:CheckBox;
		protected var _sineBox		:CheckBox;
		protected var _visualizerBg	:Sprite;
		protected var _visualizer	:Sprite;
		protected var _controlBg	:Sprite;
		protected var _button		:PushButton;
		
		protected var _playing		:Boolean;
		protected var _sound		:Sound;
		protected var _channel		:SoundChannel;
		protected var _spectrum		:ByteArray;
		
		public function WaveformExample()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			_spectrum = new ByteArray();
			_playing = false;
			
			createDisplay();
			
		
			
			stage.addEventListener( Event.ENTER_FRAME, onEnterFrame );
		}
		
		// ----------------------------------------------
		//
		// 	-- handlers
		//
		// ----------------------------------------------
		
		// -- toggles between play and stop
		protected function toggle( event:Event ):void
		{
			if( _playing ) {
				
				if( _channel ) {
					_playing = false;
					_button.label = 'Play';
					_sound.removeEventListener( SampleDataEvent.SAMPLE_DATA, onSampleData );
					_channel.stop();
				}
			}else {
				_button.label = 'Stop';
				_playing = true;
				_sound = new Sound();
				
				_sound.addEventListener( SampleDataEvent.SAMPLE_DATA, onSampleData );
				_channel = _sound.play();
			}	
		}
		
		// ----------------------------------------------
		//
		// 	-- sound
		//
		// ----------------------------------------------
		
		// -- handles pushing audio data into the buffer
		// -- in this case we are generating square and sine waves and merging them w/ addition
		protected function onSampleData( event:SampleDataEvent ):void
		{
			var sample:Number;
			for( var i:int = 0; i < 8192; i++ )
			{
				sample = 0;
				
				if( _squareBox.selected ) 
					sample += squareWave( i + event.position );
					
				if( _sineBox.selected ) 
					sample += sineWave( i + event.position );
				
				event.data.writeFloat( sample * .1 );	// -- mute the notes
		        event.data.writeFloat( sample * .1 ); 	// -- mute the notes
			}
		}
		
		// -- generates a sine wave - sin( 2 * ( pi ) * fn / R + w ) 
		private function sineWave( position:int ):Number {
			return Math.sin(  Math.PI * 2 * _knob.value * position / SAMPLE_RATE );
		}
		
		// -- generates a sqaure wave
		private function squareWave( position:int ):Number {
		    return Math.sin(  Math.PI * 2 * _knob.value * position / SAMPLE_RATE ) > 0 ? .2 : -.2;
		}
		
		
		// -- draws the visualizer
		protected function onEnterFrame( event:Event ):void
		{
			var i:int;	
			var w:int = 495;
			var h:int = 300;
			
			_visualizer.graphics.clear();
			_visualizer.graphics.lineStyle( 1, 0xf05151, 1 );
		
			if( _playing )
			{
				SoundMixer.computeSpectrum( _spectrum, false );
				
				for( i = 0; i < 255; i++ ){
					if( i == 0 ) _visualizer.graphics.moveTo( w / 255, Math.round( _spectrum.readFloat() * h ) );
					_visualizer.graphics.lineTo( (i + 1) * ( w / 255 ), Math.round( _spectrum.readFloat() * h ) );
				}
			} else {
				_visualizer.graphics.lineTo( w, 0 );
			}
		}
		
		
		// ----------------------------------------------
		//
		// 	-- graphics
		//
		// ----------------------------------------------
		
		// -- builds the u.i.
		protected function createDisplay():void
		{
			_visualizerBg 	= new Sprite();
			_visualizerBg.graphics.beginFill( 0xFFFFFF, .15 );
			_visualizerBg.graphics.drawRect( 0, 0, 495, 135 );
			_visualizerBg.graphics.endFill();
			_visualizerBg.x = 5;
			_visualizerBg.y = 5;
			
			_visualizer 	= new Sprite();
			_visualizer.x = 5;
			_visualizer.y = 72;
			_visualizer.filters = [ new GlowFilter( 0xf05151, .5, 6, 6, 2, BitmapFilterQuality.HIGH ) ]; 
			
			_controlBg = new Sprite();
			_controlBg.graphics.beginFill( 0xFFFFFF, .15 );
			_controlBg.graphics.drawRect( 0, 0, 110, 110 );
			_controlBg.graphics.endFill();
			_controlBg.x = 505;
			_controlBg.y = 5;
			
			_knob = new Knob( this, 543, 10, 'Freq' );
			_knob.minimum = MIN_PITCH;
			_knob.maximum = MAX_PITCH;
			_knob.value = 440;
			
			_button = new PushButton( this, 505, 120, 'Play', toggle );
			_button.setSize( 110, _button.height );
						
			_squareBox = new CheckBox( this, 515, 93, 'Square' );
			_squareBox.selected = true;
			
			_sineBox   = new CheckBox( this, 575, 93, 'Sine' );
			_sineBox.selected = true;
			
			addChildAt( _visualizerBg, 0 );
			addChildAt( _controlBg, 0 );
			addChild( _visualizer );
		}
	}
}
