package makemachine.audio
{
	import com.bit101.components.*;
	
	import flash.display.*;
	import flash.events.Event;
	import flash.utils.Dictionary;

	public class NoteComponent extends Sprite
	{
		public static const WIDTH	:int = 175;
		
		protected var _name			:String;
		protected var _frequency	:Number;
		protected var _amplitude	:Number;
		
		protected var _noteSlider		:HSlider;
		protected var _octaveSlider		:HSlider;
		protected var _volumeSlider		:HSlider;
		protected var _equationLabel	:Label;
		protected var _noteLabel		:Label;
		protected var _sliderLabelMap	:Dictionary;
		
		public static const notes:Array = [ 'A', 'A#', 'B', 'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#' ];
		
		/**
		 * @Constructor
		 * - has sliders for note, octave and volume
		 * - provides public methods for frequency, amplitude and randomization
		 * - displays note as frequency 
		 */
		public function NoteComponent( xpos:int, ypos:int )
		{
			super();
			
			x = xpos;
			y = ypos;
			
			_sliderLabelMap = new Dictionary();
			
			var bg:Sprite = new Sprite();
			bg.graphics.beginFill( 0xFFFFFF, .15 );
			bg.graphics.drawRect( 0, 0, WIDTH, 65 );
			bg.graphics.endFill();
			addChildAt( bg, 0 );
			
			var vbox:VBox = new VBox( this, 10, 5);
			vbox.spacing = 0;
			
			_noteSlider = createHSlider( vbox, 'Note    ', 0, 11 );
			_octaveSlider = createHSlider( vbox, 'Octave', -1, 6, 4 );
			_volumeSlider = createHSlider( vbox, 'Volume', 0, 100, 20 );
			
			bg = new Sprite();
			bg.graphics.beginFill( 0xFFFFFF, .15 );
			bg.graphics.drawRect( 0, 0, WIDTH, 20);
			bg.x = 0;
			bg.y = 70;
			addChildAt( bg, 0 );
			
			_equationLabel = new Label( this, 3, 70 );
			
			update();
		}
		
		// ----------------------------------------------
		//
		// 	-- public
		//
		// ----------------------------------------------
		
		// -- returns actual numeric frequency of note
		public function get frequency():Number {
			return _frequency;
		}
		
		// -- returns normalized floating point
		public function get amplitude():Number {
			return _amplitude;
		}
		
		// -- sets volume to a low level
		// -- sets the octave slider to either 3 or 4
		// -- sets the note slider to random position
		public function randomize():void 
		{
			_volumeSlider.value = 20;
			_octaveSlider.value = Math.random() > .5 ? 3 : 4;
			_noteSlider.value = Math.round( _noteSlider.minimum + Math.random() * ( _noteSlider.maximum - _noteSlider.minimum ) );
			update();
		}
		
		// ----------------------------------------------
		//
		// 	-- protected
		//
		// ----------------------------------------------
		 
		/**
		 * - updates the labels and sets values for _frequency and _amplitude
		 * - the octave variable needs to be offset by four because 
		 * - @ the fourth octave is actually where octave == 0 as in f = 2 ^ 1 * 440
		 * - for display purposes though we want it to display as the fourth octave as in A4 = 440
		 * - then we multiply by twelve to set the ocatve
		 * - adding the distance to the octave gives us our total ofset from A440
		 * - where n is the number of half steps away from A4 or 440Hz
		 * - freq = 2 ^ n/12 * 440 
		 * 
		 * Reference: 
		 * http://en.wikipedia.org/wiki/Note
		 * http://www.phy.mtu.edu/~suits/NoteFreqCalcs.html
		 */
		 
		protected function update( event:Event = null ):void
		{
			var label:Label;
			var dist:Number = _noteSlider.value;
			var octave:Number = ( _octaveSlider.value - 4 ) * 12;
			_frequency = Math.pow( 2, ( dist + octave ) / 12 ) * 440;
			_amplitude = _volumeSlider.value / 100;
			
			label = _sliderLabelMap[ _noteSlider ]
			label.text = notes[ dist ];
			
			label = _sliderLabelMap[ _octaveSlider ];
			label.text = String( _octaveSlider.value );
			
			label = _sliderLabelMap[ _volumeSlider ];
			label.text = String( _volumeSlider.value );
			
			_equationLabel.text = 'Freq: ' + String( _frequency ) + 'Hz';
		}
		
		// ----------------------------------------------
		//
		// 	-- graphics
		//
		// ----------------------------------------------
		
		// -- convenience method for creating a custom VSlider
		// -- we need to make our own so that we can display letters such as A# in the label
		protected function createHSlider( parent:DisplayObjectContainer, text:String, min:Number, max:Number, defaultValue:Number = -1 ):HSlider
		{
			var hbox:HBox = new HBox( parent );
			
			var label:Label = new Label( hbox, 0, 0, text );
			label.draw();
			
			var slider:HSlider = new HSlider( hbox, 0, ( label.height - 10 ) * .5, update );
			slider.minimum = min;
			slider.maximum = max;
			slider.value = defaultValue == -1 ? Math.round( min + Math.random() * ( max - min ) ) : defaultValue;
			slider.draw();
			
			label = new Label( hbox, label.height, 0, 'A#' );
			
			_sliderLabelMap[ slider ] = label;
			
			hbox.draw();
			
			return slider;
		}
	}
}