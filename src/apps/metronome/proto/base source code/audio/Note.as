package makemachine.audio
{
	/**
	 * represents one note in the metronome
     * holds own vars to create tone with
     * duration value determines how long the tone is
     * provides api for fetching freq, amp 
     * and whether or not there are more samples to add to the buffer
     * through hasNext() method
	 */
	public class Note
	{
		protected var _index	:int;
		protected var _duration	:int;
		protected var _frequency:Number;
		protected var _amp		:Number;
		
		public function Note( duration:int, freq:Number, maxAmplitude:Number = 1 ) 
		{
			_index = 0;
			_duration = duration;
			_frequency = freq;
			_amp = maxAmplitude;
		}
		
		public function getNext():int {
			return _index + 1 < _duration ? _index++ : _index;
		}
		
		public function get frequency():Number {
			return _frequency;
		}
		
		public function hasNext():Boolean {
			return _index + 1 < _duration;
		}
		
		// -- do a little fade out here to prevent pop
		public function get amplitude():Number {
			return ( 1 - ( _index / _duration ) ) * _amp;
		}

	}
}