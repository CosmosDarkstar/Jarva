/**
 * As seen here: http://labs.makemachine.net/2010/09/wavetable-synthesis-round-1/
 */
package makemachine.audio
{
	import com.bit101.components.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.media.*;
	import flash.utils.*;
	
	[SWF( backgroundColor="0x222222", width="620", height="300", frameRate="60" )]
	public class WaveletGeneratorExample extends Sprite
	{
		public static const SAMPLE_RATE	:int = 44100;
		public static const BUFFER_SIZE	:int = 4096;
		public static const WAVELET_SIZE:int = 2048;
		public static const BASE_FREQ	:Number = ( SAMPLE_RATE / WAVELET_SIZE );
		public static const PI_2		:Number = Math.PI * 2;
		public static const PI_2_OVR_SR	:Number = PI_2 / SAMPLE_RATE;
		
		// -- sound
		protected var _sound:Sound;
		protected var _channel:SoundChannel;
		
		protected var _frequency	:Number;
		protected var _mainVolume	:Number;
		protected var _step			:Number;
		protected var _wavelet		:Vector.<Number>;
		
		// -- display
		protected var _playbutton:PushButton;
		protected var _list		:List;
		
		// -- util
		protected var _playing:Boolean;
		protected var _sliders:Vector.<HUISlider>;
		protected var _presets:Array;
		
		public function WaveletGeneratorExample()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			createDisplay();
		}
		
		// -----------------------------------------
		// 
		//	-- methods
		//
		// -----------------------------------------
		
		protected function stop():void 
		{
			if( _channel && _playing ) 
			{
				_playing = false;
				_playbutton.label = 'Play';
				_playbutton.selected = false;
				_channel.stop();
				_sound.removeEventListener( SampleDataEvent.SAMPLE_DATA, onSampleData );
				_channel = null;
			}
		}
		
		protected function start():void 
		{
			_playing = true;
			_playbutton.label = 'Stop';
			_playbutton.selected = true;
			_sound.addEventListener( SampleDataEvent.SAMPLE_DATA, onSampleData );
			_channel = _sound.play();
		}
		
		
		// -----------------------------------------
		// 
		//	-- events
		//
		// -----------------------------------------
		protected function onMainVolume( event:Event ):void 
		{
			if( event.target is Knob ){
				var knob:Knob = event.target as Knob;
				_mainVolume = knob.value;
			}
		}
		
		protected function onFrequency( event:Event ):void{
			if( event.target is HUISlider ){
				var slider:HUISlider = event.target as HUISlider;
				_frequency = slider.value;
				updateStep();
			}
		}
		
		protected function toggle( event:Event ):void
		{
			_playing ? 
				stop() : 
				start();
		}
		
		protected function randomize( event:Event = null ):void
		{
			for each( var slider:HUISlider in _sliders ){
				slider.value = Math.random() * .5;
				slider.dispatchEvent( new Event( Event.CHANGE ));
			}
			_list.selectedIndex = 0
			queueUpdate();
		}
		
		protected function reset( event:Event ):void
		{
			for each( var slider:HUISlider in _sliders ){
				slider.value = 0;
				slider.dispatchEvent( new Event( Event.CHANGE )) ;
			}
			_list.selectedIndex = 0;
			queueUpdate();
		}
		
		protected function onPresetSelect( event:Event ):void
		{
			if( event.target  is List ) 
			{
				var list:List = event.target as List;
				var item:String = String( list.selectedItem );
				if( list.selectedIndex == 0 ) return;
				for( var i:int = 0; i < _presets.length; i ++ ) 
				{
					var preset:Object = _presets[i];
					if( preset.name == item ) {
						updatePreset( preset.values ) 
					}
				}
			}
		}
		
		protected function updatePreset( values:Array ):void
		{
			for( var i:int = 0; i < values.length; i++ ) {
				_sliders[ i ].value = values[i];
				_sliders[i].dispatchEvent( new Event( Event.CHANGE ) );
			}
			
			queueUpdate();
		}
		
		protected function updateStep():void {
			_step = ( _frequency / SAMPLE_RATE ) * WAVELET_SIZE;
		}
		
		protected function queueUpdate():void {
			addEventListener( Event.ENTER_FRAME, updateWavelet );
		}
		
		// -----------------------------------------
		// 
		//	-- sound
		//
		// -----------------------------------------
		
		protected var pa:Number = 0; // -- phase accumulator
		protected function onSampleData( event:SampleDataEvent ):void
		{
			var i:int;
			for( i = 0; i < BUFFER_SIZE; i++ )
			{		
				var sample:Number = _wavelet[ pa ];
				
				sample *= _mainVolume;
				event.data.writeFloat( sample );
				event.data.writeFloat( sample );
				pa = Math.round( pa + _step < _wavelet.length -1 ? pa + _step : 0 );
			}
		}
		
		// -----------------------------------------
		//	-- render / create wavelet
		// -----------------------------------------
		
		protected function updateWavelet( event:Event ):void
		{
			var xpos:Number = 5;
			var ypos:Number = 210;
			var renderw:int = 610;
			var linesize:Number = renderw / WAVELET_SIZE;
			var waveheight:Number = 50;
			
			_wavelet.slice( 0 );
			
			var i:int = 0;
			
			graphics.clear();
			graphics.beginFill( 0xFFFFFF, .1 );
			graphics.drawRect( xpos, ypos - 60, renderw, 120 );
			graphics.endFill();
			graphics.lineStyle( 1, 0x00c6FF, 1, true );
			graphics.moveTo( xpos, ypos );
			graphics.lineTo( xpos + renderw, ypos );
			graphics.moveTo( xpos, ypos );
			graphics.lineStyle( 1, 0xFF0655, 1 );
			
			for( i; i < WAVELET_SIZE; i++ ) 
			{
				var sample:Number;
				var sinewave:Number = sine(i);
				var pwm:Number = pulseWaveMod(i)
				
				sample = sinewave + saw() + square() + pwm + triangle() + noise();
				
				sample = distort( sample );
				
				sample = sample > 1 ? 1 : sample;
				sample = sample < -1 ? -1 : sample;
				
				_wavelet[i] = sample;
				sample = _wavelet[i];
				xpos += linesize;
				
				if( i == 0 ) {
					graphics.moveTo( xpos, ypos + sample * 60 )
				} else {
					graphics.lineTo( xpos, ypos + sample * 60 );
				}
			}
			
			removeEventListener( Event.ENTER_FRAME, updateWavelet );
		}
		
		// -----------------------------------------
		//  -- sine
		// -----------------------------------------
		
		protected var _sineamp:Number = 1;
		protected function sine( index:int ):Number {
			return Math.sin( Math.PI * 2 * BASE_FREQ * ( index ) / SAMPLE_RATE ) * _sineamp;
		}
		
		protected function onSineAmpChange( event:Event ):void
		{
			if( event.target is HUISlider ){
				var slider:HUISlider = event.target as HUISlider;
				_sineamp = slider.value;
				queueUpdate();
			}
		}
		
		// -----------------------------------------
		//  -- square
		// -----------------------------------------
		protected var _sqrphase	:Number = 0;
		protected var _sqramp	:Number = 1;
		
		private function square():Number 
		{
			var sample:Number = _sqrphase < Math.PI ? _sqramp : -_sqramp;
			
			_sqrphase += ( PI_2 * BASE_FREQ ) / SAMPLE_RATE;
			_sqrphase = _sqrphase > PI_2 ? _sqrphase - PI_2 : _sqrphase;
			
			return sample * _sqramp;
		}
		
		protected function onSquareAmpChange( event:Event ):void
		{
			if( event.target is HUISlider ){
				var slider:HUISlider = event.target as HUISlider;
				_sqramp = slider.value;
				queueUpdate();
			}
		}
		
		// -----------------------------------------
		//  -- saw
		// -----------------------------------------
		
		protected var _sawamp:Number = 0;
		protected var _sawphase:Number = 0;
		private function saw():Number 
		{
			var amp:Number = 1;
			var sample:Number;
			
			sample = amp - (amp / Math.PI) * _sawphase;
			_sawphase = _sawphase + ( ( PI_2 * BASE_FREQ) / SAMPLE_RATE );
			_sawphase =  _sawphase < PI_2 ? _sawphase : _sawphase - PI_2; 
			
			return sample * _sawamp;
		}
		
		protected function onSawAmpChange( event:Event ):void
		{
			if( event.target is HUISlider ){
				var slider:HUISlider = event.target as HUISlider;
				_sawamp = slider.value;
				queueUpdate();
			}
		}
		
		
		// -----------------------------------------
		//  -- triangle
		// -----------------------------------------
		
		protected var _triangleamp:Number = 0;
		protected var _trianglephase:Number = 0;
		protected function triangle():Number 
		{
			var amp:Number = 1;
			var sample:Number;
			
			if( _trianglephase < Math.PI ) {
				sample = -amp + ( 2 * amp / Math.PI ) * _trianglephase;
			} else {
				sample = ( 3 * amp ) - ( 2 * amp / Math.PI ) * _trianglephase;
			}
			
			_trianglephase = _trianglephase + ( ( PI_2 * BASE_FREQ ) / SAMPLE_RATE );
			_trianglephase = _trianglephase > ( PI_2 )  ? _trianglephase - PI_2 : _trianglephase;
			
			return sample * _triangleamp;
		}
		
		protected function onTriangleAmpChange( event:Event ):void
		{
			if( event.target is HUISlider ){
				var slider:HUISlider = event.target as HUISlider;
				_triangleamp = slider.value;
				queueUpdate();
			}
		}
		
		// -----------------------------------------
		//  -- noise
		// -----------------------------------------
		
		protected var _noiseamp:Number = .5;
		private function noise():Number 
		{
			var n:Number = -1 + 2 * Math.random();
			return Math.random() * _noiseamp * .2;
		}
		
		protected function onNoiseAmpChange( event:Event ):void
		{
			if( event.target is HUISlider ){
				var slider:HUISlider = event.target as HUISlider;
				_noiseamp = slider.value;
				queueUpdate();
			}
		}
		
		// -----------------------------------------
		//  -- pulse wave modulation
		// -----------------------------------------
		
		protected var _amplitude		:Number = 1;
		protected var _pulsewidthlow	:Number = Math.PI + .9;
		protected var _pulsewidthhigh	:Number = Math.PI - .9;
		protected var _pwmamp			:Number = 1;
		protected var _pwmspeed			:Number = 0x1200 * .5;
		protected var _ampmodspeed		:Number = 0x1000 * .5;
		protected var _pwmphase			:Number = 0;
		
		protected function pulseWaveMod( index:Number ):Number 
		{
			var pulsewidth:Number;
			var ampmod:Number;
			var sample:Number;
			
			pulsewidth = Math.sin ( index / 0x5 ) * _pulsewidthhigh + _pulsewidthlow;
			sample = 1 + ( _pwmphase < pulsewidth ? _amplitude : -_amplitude );
			_pwmphase = _pwmphase + ( PI_2_OVR_SR * BASE_FREQ );
			_pwmphase = _pwmphase > ( PI_2 ) ? _pwmphase - ( PI_2 ) : _pwmphase;
			ampmod = Math.sin ( index / ( 10 +_ampmodspeed ) );
			
			return sample * ampmod * _pwmamp;
		}
		
		protected function onAmpModSpeedChange( event:Event ):void
		{
			if( event.target is HUISlider ){
				var slider:HUISlider = event.target as HUISlider;
				_ampmodspeed = ( 1 - slider.value ) * 0x1000;
				queueUpdate()
			}
		}
		
		protected function onPulseWidthModAmountChange( event:Event ):void 
		{
			if( event.target is HUISlider ){
				var slider:HUISlider = event.target as HUISlider;
				_pwmamp = slider.value;
				queueUpdate();
			}	
		}
		
		// -----------------------------------------
		//  -- pulse wave modulation
		// -----------------------------------------
		protected var _distortion:Number = .5;
		protected function distort( sample:Number ):Number
		{
			sample = 1 * sample - _distortion * sample * sample * sample;
			return sample;
		}
		
		protected function onDistortionChange( event:Event ):void 
		{
			if( event.target is HUISlider ){
				var slider:HUISlider = event.target as HUISlider;
				_distortion = slider.value * 2;
				queueUpdate();
			}	
		}
		
		// -----------------------------------------
		//
		//  display
		//
		// -----------------------------------------
		
		protected function createDisplay():void 
		{
			_sound 		= new Sound();
			_sliders 	= new Vector.<HUISlider>();
			_mainVolume = .1;
			_wavelet = new Vector.<Number>( WAVELET_SIZE );
			
			var slider:HUISlider;
			var vbox:VBox = new VBox( this, 5, 5 );
			vbox.spacing = 0;
			
			slider = createSlider( vbox, 'Sine', onSineAmpChange );
			slider = createSlider( vbox, 'Square', onSquareAmpChange );
			slider = createSlider( vbox, 'Sawtooth', onSawAmpChange );
			slider = createSlider( vbox, 'Triangle', onTriangleAmpChange );
			slider = createSlider( vbox, 'Noise I', onNoiseAmpChange );
			slider = createSlider( vbox, 'Distortion', onDistortionChange );
			slider = createSlider( vbox, 'Pulse Wave Speed', onAmpModSpeedChange ); 
			slider = createSlider( vbox, 'Pulse Wave Ammount', onPulseWidthModAmountChange );
			
			var knob:Knob;
			var button:PushButton;
			var hbox:HBox = new HBox( this, 5, 275 );
			_playbutton = button = new PushButton( hbox, 0, 0, 'Play', toggle );
			button.toggle = true;
			
			button = new PushButton( hbox, 0, 0, 'Reset', reset );
			button = new PushButton( hbox, 0, 0, 'Randomize', randomize );
			
			slider = new HUISlider( this, 350, 295, 'Frequency', onFrequency );
			slider.minimum = 40;
			slider.maximum = 440;
			slider.value = _frequency = 100;
			slider.x = 320;
			slider.y = 275;
			slider.width = 315;
			slider.draw();
			
			_presets = [];
			
			_presets[0] = { name: 'None', values: {} }
				_presets[1] = { name:'Sine', values: [ .5, 0, 0, 0, 0, 0, 0, 0 ] } 
			_presets[2] = { name:'Square', values: [  0, .5, 0, 0, 0, 0, 0, 0 ] } 
			_presets[3] = { name:'Saw', values: [ 0, 0, .5, 0, 0, 0, 0, 0 ] } 
			_presets[4] = { name:'Triangle', values: [ 0, 0, 0, .5, 0, .0, 0, 0 ] } 
			_presets[5] = { name:'Pulse Wave', values: [ 0, 0, 0, 0, 0, .0, .9, .5 ] } 
			
			var items:Array = [];
			for( var i:int = 0; i < _presets.length; i++ ) {
				items.push( _presets[i].name );
			}
			
			_list = new List( this, 515, 5, items );
			_list.width = 100;
			_list.height = 140;
			_list.alternateRows = true;
			_list.alternateColor = 0x4b4b4b;
			_list.defaultColor  = 0x444444;
			_list.rolloverColor = 0x888888;
			_list.selectedColor = 0xFFFFFF;
			_list.addEventListener( Event.SELECT, onPresetSelect );
			randomize();
			updateStep();
		}
		
		protected function createSlider( parent:DisplayObjectContainer, label:String, callback:Function ):HUISlider
		{
			var slider:HUISlider = new HUISlider( parent, 0, 0, label, callback );
			slider.minimum = .00001
			slider.maximum = 1;
			slider.value = .5;
			slider.labelPrecision = 5;
			slider.tick = .00001
			slider.width = 510;
			
			_sliders.push( slider );
			
			return slider;
		}
	}
}