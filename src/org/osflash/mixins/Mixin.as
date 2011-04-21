package org.osflash.mixins
{
	import org.osflash.signals.ISignal;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class Mixin implements IMixin
	{
		
		/**
		 * 
		 */
		private var _completedSignal : ISignal;
		
		/**
		 * 
		 */
		private var _errorSignal : ISignal;
		
		/**
		 * 
		 */
		public function Mixin()
		{
		}
		
		/**
		 * @inheritDoc
		 */
		public function add(descriptor : Class, implementation : Class) : IMixinBinding
		{
			return null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function remove(descriptor : Class) : IMixinBinding
		{
			return null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function removeAll() : void
		{
			
			
			_completedSignal.removeAll();
			_errorSignal.removeAll();
		}
		
		/**
		 * @inheritDoc
		 */
		public function define(implementation : Class) : void
		{
		}
		
		/**
		 * @inheritDoc
		 */
		public function create(definitive : Class) : void
		{
		}
		
		/**
		 * @inheritDoc
		 */
		public function addObserver(observer : IMixinObserver) : void
		{
			_errorSignal.add(observer.mixinErrorSiginal);
			_completedSignal.add(observer.mixinCompletedSignal);
		}
		
		/**
		 * @inheritDoc
		 */
		public function removeObserver(observer : IMixinObserver) : void
		{
			_errorSignal.remove(observer.mixinErrorSiginal);
			_completedSignal.remove(observer.mixinCompletedSignal);
		}

		
	}
}