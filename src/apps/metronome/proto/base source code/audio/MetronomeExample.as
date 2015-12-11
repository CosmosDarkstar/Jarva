/**
 * As seen here: http://labs.makemachine.net/2010/06/metronome/
 */

package makemachine.audio
{
	import com.bit101.components.*;
	
	import flash.display.*
	import flash.events.*;
	import flash.media.*;
	import flash.utils.*;

	[SWF( backgroundColor="0x222222", width="315", height="100", frameRate="60" )]
	public class MetronomeExample extends Sprite
	{
		// -- constants
		public static const MIN_TEMPO			:int = 60;
		public static const MAX_TEMPO			:int = 160;
		public static const SAMPLE_RATE			:int = 44100;
		public static const SECONDS_PER_MINUTE	:int = 60;
		public static const BUFFER_SIZE			:int = 8192;
		public static const NOTE_DURATION		:int = 700; // in samples
		public static const TIME_3_4			:String = '3/4';
		public static const TIME_4_4			:String = '4/4';
		public static const EIGHTH_NOTES		:String = '8th Notes';
		public static const SIXTEENTH_NOTES		:String = '16th Notes';
		
		// -- graphics
		protected var _knob			:Knob;
		protected var _button		:PushButton;
		protected var _rbtns		:Array;
		
		// -- sound
		protected var _sound		:Sound;
		protected var _channel		:SoundChannel;
		protected var _tempo		:int;
		protected var _playing		:Boolean;
		protected var _notes		:Array;
		protected var _signature	:String;
		protected var _playEnabled	:Boolean;
		protected var _step			:int;
		protected var _eighthnotes	:Boolean;
		protected var _sxthnnotes	:Boolean;
		
		// -- util
		protected var _timer	:Timer;
		
		public function MetronomeExample()
		{
			super();
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			_step = 0;
			_notes = [];
			_rbtns = [];
			_signature = TIME_4_4;
			_timer = new Timer( 500 );
			_eighthnotes = true;
			_sxthnnotes = false;
			
			createDisplay();
		}
		
		// ----------------------------------------------
		//
		// 	-- handlers
		//
		// ----------------------------------------------
		
		// -- stops audio and starts a timer that when complete
		// -- sets the tempo to the knob's value and restarts the audio
		// -- using a timer is preffered because it makes for smoother playback
		protected function onTempoKnobChange( event:Event ):void 
		{
			_timer.stop();
			_timer.start();
			stop();
			_timer.addEventListener( TimerEvent.TIMER, onTempoTimer );
		}
		
		
		protected function onTempoTimer( event:TimerEvent ):void
		{
			_tempo = _knob.value;
			_timer.removeEventListener( TimerEvent.TIMER, onTempoTimer );
			_playEnabled ?  play() : null;
		}
		
		
		// -- toggles between play and stop
		protected function toggle( event:Event ):void 
		{			
			if( _playing ) {
				_playEnabled = false;
				stop();
			} else {
				_playEnabled = true;
				 play();
			}
		}
		
		// -- sets the time signature
		protected function onTimeSignatureSelection( event:Event ):void
		{
			stop();
			for each( var btn:RadioButton in _rbtns ) {
				if( btn.selected ) {
					_signature = btn.label;
				}
			}
			
			_playEnabled ?  play() : null;
		}
		
		// -- sets booleans for note selection
		protected function onNoteSelection( event:Event ):void
		{
			if( event.target is CheckBox ) 
			{
				var checkbox:CheckBox = event.target as CheckBox;
				switch( checkbox.label ) 
				{
					case EIGHTH_NOTES:
						_eighthnotes = checkbox.selected;
					break;
					
					case SIXTEENTH_NOTES:
						_sxthnnotes = checkbox.selected;
					break;
				}
			}
		}
		
		// ----------------------------------------------
		//
		// 	-- sound
		//
		// ----------------------------------------------
		
		// -- starts playback, updates u.i. and initializes some vars
		protected function play():void 
		{
			_button.label = 'Stop';
			_step = -1;
			_playing = true;
			_sound = new Sound();
			_notes = [];
			_sound.addEventListener( SampleDataEvent.SAMPLE_DATA, onSampleData );
			_channel = _sound.play();
		}
		
		// -- stops playback and updates u.i.
		protected function stop():void 
		{
			if( _channel ) 
			{
				_playing = false;
				_button.label = 'Play';
				_sound.removeEventListener( SampleDataEvent.SAMPLE_DATA, onSampleData );
				_channel.stop();
			}
		}
		
		protected function onSampleData( event:SampleDataEvent ):void
		{
			var position:int;
			
			for( var i:int = 0; i < BUFFER_SIZE; i++ ) 
			{
				position = event.position + i;
				
				// -- hope to find a better way to determine timing vars
				// -- approach for adding notes to the queue seems to work well though
			
				var n:int;
				
				// -- 3/4 time
				if( _signature == TIME_3_4 ) 
				{
					n  = position / ( SAMPLE_RATE / _tempo * SECONDS_PER_MINUTE / 12 );
					if( n != _step ) 
					{
						_step = n;
						
						if( _step % 24 == 0 ) {
							_notes.push( new Note( NOTE_DURATION, 1760 ) );	
						} else if( _step % 8 == 0 ) {
							_notes.push( new Note( NOTE_DURATION * .25, 880, .5 ) );
						}
					}
				}
				
				// -- 4/4 time
				if( _signature  == TIME_4_4 ) 
				{
					n  = position / ( SAMPLE_RATE / _tempo * SECONDS_PER_MINUTE / 32  );
					
					if( n != _step ) 
					{
						_step = n;
						// -- whole note
						if( _step % 128 == 0 ) {
							_notes.push( new Note( NOTE_DURATION, 1760 ) );
						// -- quater
						} else if( _step % 32 == 0 )  {
							_notes.push( new Note( NOTE_DURATION, 880, .7 ) );
						// -- 8th notes
						} else if( _eighthnotes && _step % 16 == 0 )  {
							_notes.push( new Note( NOTE_DURATION, 440, .5 ) );
						// -- 16th notes
						}else if( ( _step % 8 == 0  ) && _sxthnnotes ) {
							_notes.push( new Note( NOTE_DURATION * .5, 220, .5 ) );
						}
					}
				}
				
				// -- create the samples, if there are multiple notes in the queue we us addition to merge them
				var sample:Number = 0;
				for each( note in _notes )  {
					if( note.hasNext() ) {
						sample += Math.sin( Math.PI * 2 *  note.frequency * 
												( note.getNext() ) /
													 SAMPLE_RATE ) * note.amplitude;
					} 
				}
				
				// -- normalize the volume, if there are multiple notes in the list at once 
				// -- their amplitudes may add up and cause distortion
				//sample /= _notes.length > 0 ? _notes.length : 1;
				
				event.data.writeFloat( sample * .8 );
				event.data.writeFloat( sample * .8 );
			}
			
			// -- store left over notes in new array for next iteration
			// -- notes can be left over if not all positions were written to the buffer
			// -- for instance, if a note with a duration of 1000 samples starts writing to the buffer @
			// -- iteration 8000, only 192 samples are written
			var temp:Array = [];
			var note:Note;
			
			for each( note in _notes ) {
				if( note.hasNext() ) {
					temp.push( note );
				}
			}
			
			_notes = temp;
		}
		
		// ----------------------------------------------
		//
		// 	-- graphics
		//
		// ----------------------------------------------
		
		// -- builds the u.i.
		protected function createDisplay():void
		{
			var bg:Sprite;
			bg = getRectangle( 100, 90, 5, 5, .15 );
			addChild( bg );
			
			_knob = new Knob( this, 35, 10, 'Tempo ( BPM )', onTempoKnobChange );
			_knob.minimum = MIN_TEMPO;
			_knob.maximum = MAX_TEMPO;
			_knob.labelPrecision = 0;
			_knob.value = _tempo = 90;
			
			bg = getRectangle( 200, 65, 110, 5, .1 );
			addChild( bg );
			
			var vbox:VBox;
			var label:Label;
			var checkbox:CheckBox;
			
			// -- signature
			vbox = new VBox( this, 120, 10 );
			label = new Label( vbox, 0, 0, 'Time Signature' );

			_rbtns.push( new RadioButton( vbox, 0, 0, TIME_4_4, true, onTimeSignatureSelection ) );
			_rbtns.push( new RadioButton( vbox, 0, 0, TIME_3_4, false, onTimeSignatureSelection ) );
			
			// -- notes
			vbox = new VBox( this, 200, 10 );
			label = new Label( vbox, 0, 0, 'Notes (4/4 only)' );
			checkbox = new CheckBox( vbox, 0, 0, EIGHTH_NOTES, onNoteSelection );
			checkbox.selected = true;
			checkbox = new CheckBox( vbox, 0, 0, SIXTEENTH_NOTES, onNoteSelection );
			checkbox.selected = false;
			
			// -- play button
			_button = new PushButton( this, 110, 75, 'Play', toggle );
			_button.width = 200;
			_button.toggle = true;
		}
		
		protected function getRectangle( w:int, h:int, xpos:int, ypos:int, a:Number ):Sprite
		{
			var s:Sprite = new Sprite();
			s.graphics.beginFill( 0xFFFFFF, a );
			s.graphics.drawRect( 0, 0, w, h );
			s.graphics.endFill();
			s.x = xpos;
			s.y = ypos;
			return s
		}
	}
}
