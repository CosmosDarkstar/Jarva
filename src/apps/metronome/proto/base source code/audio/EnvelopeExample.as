/**
 * As seen here: http://labs.makemachine.net/2010/06/envelope-generator/
 */
package makemachine.audio
{
	import com.bit101.components.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.geom.*;
	import flash.media.*;
	
	[SWF( backgroundColor="0x222222", width="620", height="240", frameRate="60" )]
	public class EnvelopeExample extends Sprite
	{
		public static const SAMPLE_RATE	:int = 44100;
		public static const BUFFER_SIZE	:int = 8192;
		public static const GRAPH_WIDTH	:int = 610;
		public static const GRAPH_HEIGHT:int = 140;
		public static const PADDING		:int = 5;
		public static const FREQ		:Number = 440;
		
		protected var _attackKnob	:Knob;
		protected var _decayKnob	:Knob;
		protected var _sustainKnob	:Knob;
		protected var _releaseKnob	:Knob;
		protected var _button		:PushButton;
		protected var _graphBg		:Sprite;
		protected var _controlsBg	:Sprite;
		protected var _graph		:Sprite;
		protected var _playhead		:Sprite;
		
		protected var _sound		:Sound;
		protected var _channel		:SoundChannel;
		protected var _amplitude	:Number;
		protected var _playing		:Boolean;
		protected var _total		:Number;
		protected var _attack		:Number;
		protected var _decay		:Number
		protected var _sustain		:Number;
		protected var _release		:Number;
		
		
		public function EnvelopeExample() 
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			createDisplay();
		}
		
		// ----------------------------------------------
		//
		// 	-- sound
		//
		// ----------------------------------------------
		// -- toggles between play and stop
		protected function toggle( event:MouseEvent ):void
		{	
			_playing ? 
				stop() : 
					play();
		}
		
		// -- updated the u.i.
		// -- takes a 'snapshot' of sorts of the current knob settings
		// -- multiplying the values by the sample rate converts the knob values representing seconds
		// -- to representing samples, this makes it very easy to compare adsr 
		// -- values with the current position of the sound data
		// -- starts audio
		protected function play():void
		{
			_button.label = 'Stop';
			_playing = true;
			_amplitude = 0;
			_attack = _attackKnob.value * SAMPLE_RATE;
			_decay = _decayKnob.value * SAMPLE_RATE;
			_sustain = _sustainKnob.value;
			_release = _releaseKnob.value * SAMPLE_RATE;
			
			_total = _attack + _decay + _release;
			_sound = new Sound();
			_sound.addEventListener( SampleDataEvent.SAMPLE_DATA, onSampleData );
			_channel = _sound.play();
			
			addEventListener( Event.ENTER_FRAME, onEnterFrame );
		}
		
		// -- updates u.i.
		// -- stops audio
		protected function stop():void
		{
			if( _channel )
			{
				_playing = false;
				_button.label = 'Play';
				_playhead.scaleX = 0;
				_sound.removeEventListener( SampleDataEvent.SAMPLE_DATA, onSampleData );
				removeEventListener( Event.ENTER_FRAME, onEnterFrame );
				_channel.stop();
			}
		}
		
		// -- handles pushing data into the audio buffer
		// -- uses the 'snapshot' of knob settings to compare current sample index 
		// -- to the adsr values to determine how to affect the amplitude of the sound
		protected function onSampleData( event:SampleDataEvent ):void
		{
			var sample:Number;
			var position:Number;
			var ad:Number = 0; // amp delta
			var td:Number = 0; // time delta
			
			for( var i:int = 0; i < 8192; i++ )
			{
				position = i + event.position;
				
				// -- using addition to stack three notes and a little noise
				sample = Math.sin(  Math.PI * 2 * FREQ * position / SAMPLE_RATE );
				sample += Math.sin(  Math.PI * 2 * ( FREQ * 2 * .2 )  * position / SAMPLE_RATE );
				sample += Math.sin(  Math.PI * 2 * ( FREQ * 2 * .4 )  * position / SAMPLE_RATE );
				sample += Math.random() * .07;
				sample /= 3
				
				// -- attack
				if( position < _attack ) {
					_amplitude = position / _attack; 
				}
	
				// -- decay / sustain
				if( position < _total - _release )
				{
					ad = _amplitude - _sustain;
					td = ( _decay + _attack ) - position;
					_amplitude -= ad / td;
				}
				
				// -- release
				if( position > _attack + _decay && position < _total )
				{
					ad = _amplitude;
					td = _total - position;
					_amplitude -= ad / td;
				}
				
				sample *= _amplitude;
			
				event.data.writeFloat( sample );
		        event.data.writeFloat( sample );
			}
		}
		
		// -- update the progress bar
		// -- convert the milliseconds elapsed to samples elapsed and check to see if we should stop
		protected function onEnterFrame( event:Event ):void
		{
			if( _channel ) {
				var position:Number = _channel.position * 44.1;
				_playhead.scaleX = position / _total;
				if( position > _total ) {
					stop();
				}
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
			_graphBg = new Sprite();
			_graphBg.graphics.beginFill( 0xFFFFFF, .1 );
			_graphBg.graphics.drawRect( 0, 0, GRAPH_WIDTH, GRAPH_HEIGHT );
			_graphBg.graphics.endFill();
			_graphBg.x = PADDING;
			_graphBg.y = PADDING;
			
			_graph = new Sprite();
			_graph.x = PADDING * 2;
			_graph.y = GRAPH_HEIGHT;
			_graph.filters = [ new  GlowFilter( 0xf05151, .5, 6, 6, 2, BitmapFilterQuality.HIGH ) ]; 
			
			_controlsBg = new Sprite();
			_controlsBg.graphics.beginFill( 0xFFFFFF, .1 );
			_controlsBg.graphics.drawRect( 0, 0, GRAPH_WIDTH, 85 );
			_controlsBg.graphics.endFill();
			_controlsBg.x = PADDING;
			_controlsBg.y = PADDING * 2 + GRAPH_HEIGHT;
			
			_playhead = new Sprite();
			_playhead.graphics.beginFill( 0xFFFFFF, .1 );
			_playhead.graphics.drawRect( 0, 0, GRAPH_WIDTH - ( PADDING * 2 ), GRAPH_HEIGHT - ( PADDING * 2 ) );
			_playhead.graphics.endFill();
			_playhead.x = PADDING * 2;
			_playhead.y = PADDING * 2;
			_playhead.scaleX = 0;
			
			var hbox:HBox = new HBox( this, PADDING * 2, GRAPH_HEIGHT + ( PADDING * 3 ) );
			hbox.spacing = 30;
			
			_attackKnob = getKnob( hbox, 'Attack', .01, 4 );
			_decayKnob  = getKnob( hbox, 'Decay', 0, 4 );
			_sustainKnob = getKnob( hbox, 'Sustain', .01, 1 );
			_releaseKnob = getKnob( hbox, 'Release', .01, 4 );
			
			_button = new PushButton( hbox, 0, 30, 'Play', toggle );
			_button.width = 100;
			
			hbox.draw();
			hbox.x = ( stage.stageWidth - hbox.width ) * .5
			
			addChildAt( _controlsBg, 0 );
			addChildAt( _playhead, 0 );
			addChildAt( _graph, 0 );
			addChildAt( _graphBg, 0 );
			
			onKnobValueChange();
		}
		
		// -- slightly hacked together visual representation of adsr
		protected function onKnobValueChange( event:Event = null ):void
		{
			stop();
			_graph.graphics.clear();
			_graph.graphics.lineStyle( 1, 0xf05151, 1 );
			
			var seconds:Number = _attackKnob.value + _decayKnob.value + _releaseKnob.value;
			
			//var kp:Number;
			var gp:Number; 
			var p:Point = new Point();
			
			// attack
			gp = _attackKnob.value / seconds;
			p.x = gp * ( GRAPH_WIDTH - ( PADDING * 2 ) );
			p.y = -110;
			_graph.graphics.lineTo( p.x , p.y );
			
			// decay
			gp = _decayKnob.value / seconds;
			p.x += gp * ( GRAPH_WIDTH - ( PADDING * 2  ) );
			p.y = -110 * _sustainKnob.value;
			_graph.graphics.lineTo( p.x , p.y );
			
			// release
			gp = _releaseKnob.value / seconds;
			_graph.graphics.lineTo( GRAPH_WIDTH - ( PADDING * 2 ), 0 );
		}
		
		protected function getKnob( parent:DisplayObjectContainer, label:String, min:Number, max:Number ):Knob
		{
			var knob:Knob = new Knob( parent, 0, 0, label, onKnobValueChange );
			knob.minimum = min;
			knob.maximum = max;
			knob.labelPrecision = 2;
			knob.value = max * .5;
			knob.draw();
			return knob;
		}
	}
}
