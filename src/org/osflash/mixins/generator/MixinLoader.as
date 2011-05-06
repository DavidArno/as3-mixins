package org.osflash.mixins.generator
{
	import org.flemit.SWFHeader;
	import org.flemit.SWFWriter;
	import org.flemit.bytecode.IByteCodeLayout;
	import org.flemit.tags.DoABCTag;
	import org.flemit.tags.EndTag;
	import org.flemit.tags.FileAttributesTag;
	import org.flemit.tags.FrameLabelTag;
	import org.flemit.tags.ITag;
	import org.flemit.tags.ScriptLimitsTag;
	import org.flemit.tags.SetBackgroundColorTag;
	import org.flemit.tags.ShowFrameTag;
	import org.osflash.mixins.IMixin;
	import org.osflash.mixins.generator.uid.UID;
	import org.osflash.mixins.mixin_internal;

	import flash.display.Loader;
	import flash.errors.IllegalOperationError;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class MixinLoader implements IMixinLoader
	{
		/**
		 * The current SWF header version for the loader to generate.
		 */
		public static const SWF_HEARDER_TYPE : int = 10;
		
		/**
		 * @private
		 */
		private const _mixins : Vector.<IMixin> = new Vector.<IMixin>();
		
		/**
		 * @private
		 */
		private const _layouts : Vector.<IByteCodeLayout> = new Vector.<IByteCodeLayout>();
		
		/**
		 * @private
		 */
		private var _domain : ApplicationDomain;
		
		/**
		 * @private
		 */
		private const _buffer : ByteArray = new ByteArray();
		
		/**
		 * @private
		 */
		private const _loader : Loader = new Loader();
		
		/**
		 * @private
		 */
		private const _header : SWFHeader = new SWFHeader(SWF_HEARDER_TYPE);
		
		/**
		 * @private
		 */
		private const _writer : SWFWriter = new SWFWriter();
		
		/**
		 * 
		 */		
		public function add(mixin : IMixin) : IMixin
		{
			if(null == mixin) throw new ArgumentError('Given mixin can not be null');
			
			if(_mixins.indexOf(mixin) != -1)
				_mixins.push(mixin);
			else
				throw new ArgumentError('Given mixin can not be added again, without ' + 
																		'calling remove().');
			return mixin;
		}
		
		/**
		 * 
		 */
		public function remove(mixin : IMixin) : IMixin
		{
			if(null == mixin) throw new ArgumentError('Given mixin can not be null');
			
			const index : int = _mixins.indexOf(mixin);
			if(index >= 0) _mixins.splice(index, 1);
			
			return mixin;
		}
		
		/**
		 * 
		 */
		public function contains(mixin : IMixin) : Boolean
		{
			return _mixins.indexOf(mixin) >= 0;
		}
		
		/**
		 * 
		 */
		public function load(domain : ApplicationDomain = null) : MixinLoaderSignals
		{
			const total : int = _mixins.length;
			if(total == 0) throw new ArgumentError('No mixins to load, consider adding some.');
			
			_domain = null == domain ? ApplicationDomain.currentDomain : domain;
			
			// create a writer.
			const tags : Vector.<ITag> = new Vector.<ITag>();
			tags[0] = new FileAttributesTag(false, false, false, true, true);
			tags[1] = new ScriptLimitsTag();
			tags[2] = new SetBackgroundColorTag(0xFF, 0x0, 0x0);
			
			for(var i : int = 0; i<total; i++)
			{
				const mixin : IMixin = _mixins[i];
				
				try
				{
					const layout : IByteCodeLayout = mixin.mixin_internal::buildByteCodeLayout();
				}
				catch(error : Error)
				{
					throw new IllegalOperationError('Unable to generate the bytecode for mixin ' + 
																				'(' + mixin + ')');
				}
				
				_layouts.push(layout);
				
				const id : String = UID.create();
				tags.push(	new FrameLabelTag("MixinFrameLabel" + id),
							new DoABCTag("MixinGenerated" + id, layout),
							new ShowFrameTag()
							);	
			}
			
			tags.push(new EndTag());
			
			_writer.write(_buffer, _header, tags);
			
			_buffer.position = 0;
			
			// Add the loader context
			const loaderContext:LoaderContext = new LoaderContext(false, _domain);
			enableAIRDynamicExecution(loaderContext);
			
			//
			//new FileReference().save(_buffer, "dump.swf");
			//_buffer.position = 0;
			//
			
			// Loader the buffer to the loaded bytes
			_loader.loadBytes(_buffer, loaderContext);
			
			_buffer.position = 0;
			_buffer.length = 0;
			
			return new MixinLoaderSignals(mixins, this);
		}
		
		/**
		 * Needed for all AIR applications. Otherwise code execution will not work.
		 * 
		 * @param loaderContext LoaderContext for which to allow conde excution to work on.
		 */
		protected function enableAIRDynamicExecution(loaderContext:LoaderContext) : void
		{
			if (loaderContext.hasOwnProperty("allowLoadBytesCodeExecution"))
			{
				loaderContext["allowLoadBytesCodeExecution"] = true;
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function dispose() : void
		{
			_mixins.length = 0;
			
			_domain = null;
			
			_buffer.position = 0;
			_buffer.length = 0;
			
			if(null != _layouts)
			{
				var index : int = _layouts.length;
				while(--index > -1)
				{
					const layout : IByteCodeLayout = _layouts.pop();
					layout.dispose();
				}
			}
			
			try
			{
				_loader.unloadAndStop(true);	
			}
			catch(error : Error) {};
		}
		
		public function get mixins() : Vector.<IMixin>
		{
			return _mixins;
		}

		/**
		 * @inheritDoc
		 */
		public function get loader() : Loader
		{
			return _loader;
		}
	}
}
