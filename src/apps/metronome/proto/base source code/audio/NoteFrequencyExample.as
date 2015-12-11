/**
 * As seen here: http://labs.makemachine.net/2010/06/note-frequency/
 */
package makemachine.audio
{
	import com.bit101.components.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.media.*;
	
	import makemachine.examples.audio.gui.NoteComponent;

	[SWF( backgroundColor="0x222222", stageAlign="topLeft", scaleMode="noScale", width="620", height="100", frameRate="60" )]
	public class NoteFrequencyExample extends Sprite
	{
		public static const SAMPLE_RATE	:int = 44100;
		public static const BUFFER_SIZE	:int = 8192;
		public static const MAX_FREQ	:int = 880;
		public static const MIN_FREQ	:int = 440;
		
		protected var _playing			:Boolean;
		protected var _sound			:Sound;
		protected var _channel			:SoundChannel;
		
		protected var _toggleButton		:PushButton;
		protected var _randomizeButton	:PushButton;
		protected var _noteComponents	:Array;
		
		public function NoteFrequencyExample() 
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			createDisplay();
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
					_toggleButton.label = 'Play »';
					_sound.removeEventListener( SampleDataEvent.SAMPLE_DATA, onSampleData );
					_channel.stop();
				}
			} else {
				_playing = true;
				_toggleButton.label = 'Stop';
				_sound = new Sound();
				_sound.addEventListener( SampleDataEvent.SAMPLE_DATA, onSampleData );
				_channel = _sound.play();
			}	
		}
		
		// -- loop through each component and call randomize
		protected function onRandomButton( event:Event ):void
		{
			var comp:NoteComponent;
			for( var i:int = 0; i < _noteComponents.length; i++ ){
				comp = _noteComponents[i];
				comp.randomize();
			}
		}
		
		// ----------------------------------------------
		//
		// 	-- sound
		//
		// ----------------------------------------------
		
		// -- handles pushing audio data into buffer
		// -- add up the frequencies from each note component 
		protected function onSampleData( event:SampleDataEvent ):void
		{
			var sample:Number;
			for( var i:int = 0; i < 8192; i++ )
			{
				sample = 0;
				var comp:NoteComponent; 
				for( var j:int = 0; j < _noteComponents.length; j++ ) {
					comp = _noteComponents[j];
					sample += Math.sin( Math.PI * 2 * comp.frequency * ( event.position + i ) / SAMPLE_RATE ) * comp.amplitude;
				}
				sample /= _noteComponents.length;
				event.data.writeFloat( sample );
				event.data.writeFloat( sample );
			}
		}
		
		// ----------------------------------------------
		//
		// 	-- graphics
		//
		// ----------------------------------------------
		
		protected function createDisplay():void
		{
			_noteComponents = [];
			for( var i:int = 0; i < 3; i++ )
			{
				_noteComponents.push( 
					addChild( new NoteComponent( 5 + i * NoteComponent.WIDTH + ( i * 5 ), 5 ) ) );
			}
			
			_toggleButton = new PushButton( this, 545, 5, "Play »", toggle );
			_toggleButton.height = 45;
			_toggleButton.width = 70;
			_toggleButton.toggle = true;
			
			_randomizeButton = new PushButton( this, 545, 55, "Randomize", onRandomButton );
			_randomizeButton.height = 40;
			_randomizeButton.width = 70;
		}

	}
}
