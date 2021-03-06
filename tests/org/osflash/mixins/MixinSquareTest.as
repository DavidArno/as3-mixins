package org.osflash.mixins
{
	import org.flemit.bytecode.QualifiedName;
	import asunit.asserts.assertEquals;
	import asunit.asserts.assertNotNull;
	import asunit.asserts.assertTrue;
	import asunit.asserts.fail;
	import asunit.framework.IAsync;
	import org.osflash.mixins.generator.signals.IMixinLoaderSignals;
	import org.osflash.mixins.support.shape.ISquare;
	import org.osflash.mixins.support.shape.defs.IName;
	import org.osflash.mixins.support.shape.defs.IPosition;
	import org.osflash.mixins.support.shape.defs.ISize;
	import org.osflash.mixins.support.shape.impl.NameImpl;
	import org.osflash.mixins.support.shape.impl.PositionImpl;
	import org.osflash.mixins.support.shape.impl.SizeImpl;




	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class MixinSquareTest
	{
		
		[Inject]
		public var async : IAsync;
						
		protected var mixin : IMixin; 
		
		protected var mixinName : String;
		
		[Before]
		public function setUp():void
		{
			mixin = new Mixin();
		}
		
		[After]
		public function tearDown():void
		{
			mixinName = null;
			
			mixin.removeAll();
			mixin = null;
		}
		
		[Test]
		public function create_square_mixin_and_verify_creation() : void
		{
			mixin.add(IPosition, PositionImpl);
			mixin.add(ISize, SizeImpl);
			mixin.add(IName, NameImpl);
			
			mixin.define(ISquare);
			
			const signals : IMixinLoaderSignals = mixin.generate();
			signals.completedSignal.add(async.add(verifyCreationISquareImplementation, 1000));
			signals.errorSignal.add(failIfCalled);
		}

		private function verifyCreationISquareImplementation(mixin : IMixin) : void
		{
			const impl : ISquare = mixin.create(ISquare, {regular:true});
			
			assertNotNull('ISquare implementation is not null', impl);			
			assertTrue('Valid creation of ISquare implementation', impl is ISquare);
			assertTrue('Valid creation of ISize implementation', impl is ISize);
			assertTrue('Valid creation of IPosition implementation', impl is IPosition);
		}
		
		
		[Test]
		public function create_square_mixin_and_verify_getName() : void
		{
			mixin.add(IPosition, PositionImpl);
			mixin.add(ISize, SizeImpl);
			mixin.add(IName, NameImpl);
			
			const binding : IMixinNamedBinding = mixin.define(ISquare);
			const qname : QualifiedName = binding.name;
			mixinName = qname.name;
			
			const signals : IMixinLoaderSignals = mixin.generate();
			signals.completedSignal.add(async.add(verifyGetName, 1000));
			signals.errorSignal.add(failIfCalled);
		}
		
		private function verifyGetName(mixin : Mixin) : void
		{
			const impl : ISquare = mixin.create(ISquare, {regular:true});
			
			assertEquals('ISquare getName should be equal to class name', mixinName, impl.toString());
		}
		
		[Test]
		public function create_square_mixin_and_add_radius() : void
		{
			mixin.add(IPosition, PositionImpl);
			mixin.add(ISize, SizeImpl);
			mixin.add(IName, NameImpl);
			
			mixin.define(ISquare);
			
			const signals : IMixinLoaderSignals = mixin.generate();
			signals.completedSignal.add(async.add(addWidthAndVerifyAddition, 1000));
			signals.errorSignal.add(failIfCalled);
		}
		
		private function addWidthAndVerifyAddition(mixin : Mixin) : void
		{
			const impl : ISquare = mixin.create(ISquare, {regular:true});
			
			impl.width = 5;
			
			assertEquals('ISquare width should be equal to 5', impl.width, 5);
			
			impl.height = 1;
			
			assertEquals('ISquare height should be equal to 1', impl.height, 1);
		}
		
		[Test]
		public function create_square_mixin_and_add_width_multiple_times() : void
		{
			mixin.add(IPosition, PositionImpl);
			mixin.add(ISize, SizeImpl);
			mixin.add(IName, NameImpl);
			
			mixin.define(ISquare); 
			
			const signals : IMixinLoaderSignals = mixin.generate();
			signals.completedSignal.add(async.add(addSizeMultipleTimesAndVerifyAddition, 1000));
			signals.errorSignal.add(failIfCalled);
		}
		
		private function addSizeMultipleTimesAndVerifyAddition(mixin : Mixin) : void
		{
			const impl : ISquare = mixin.create(ISquare, {regular:true});
			
			for(var i : int = 0; i<1000; i++)
			{
				const width : int = int(Math.random() * Number.MAX_VALUE);
				
				impl.width = width;
				
				assertEquals('ISquare width should be equal to ' + width, impl.width, width);
				
				const height : int = int(Math.random() * Number.MAX_VALUE);
				
				impl.height = height;
				
				assertEquals('ISquare height should be equal to ' + height, impl.height, height);
			}
		}
		
		[Test]
		public function create_multiple_square_mixins() : void
		{
			mixin.add(IPosition, PositionImpl);
			mixin.add(ISize, SizeImpl);
			mixin.add(IName, NameImpl);
			
			mixin.define(ISquare);
			
			const signals : IMixinLoaderSignals = mixin.generate();
			signals.completedSignal.add(async.add(	verifyCreationOfMultipleISquareImplementation, 
													1000
													));
			signals.errorSignal.add(failIfCalled);
		}
		
		private function verifyCreationOfMultipleISquareImplementation(mixin : Mixin) : void
		{
			for(var i : int = 0; i<1000; i++)
			{
				const impl : ISquare = mixin.create(ISquare, {regular:true});
			
				assertNotNull('ISquare implementation is not null', impl);			
				assertTrue('Valid creation of ISquare implementation', impl is ISquare);
				assertTrue('Valid creation of ISize implementation', impl is ISize);
				assertTrue('Valid creation of IPosition implementation', impl is IPosition);
			}
		}
		
		private function failIfCalled(mixin : IMixin, mixinError : MixinError) : void
		{
			fail('Failed to create mixin (' + mixin + ") with error " + mixinError);
		}
	}
}
