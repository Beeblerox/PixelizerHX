package pixelizer.utils;

import nme.utils.ByteArray;

/**
 * Holds a sequence of input states.
 */
class PxInputSequence 
{
	
	private var _posts:Array<PxInputPost>;
	private var _currentPost:PxInputPost;
	private var _position:Int;
	private var _postPosition:Int;
	
	/**
	 * Creates a new sequence.
	 */
	public function new() 
	{
		_posts = new Array<PxInputPost>();
		_position = 0;
		_postPosition = 0;
		_currentPost = null;
	}
	
	/**
	 * Resets the sequence.
	 */
	public function reset():Void 
	{
		_position = 0;
		_postPosition = 0;
		_posts = new Array<PxInputPost>();
		_currentPost = null;
	}
	
	/**
	 * Restarts the sequence. All data is kept, but start from the beginning.
	 */
	public function restart():Void 
	{
		_position = 0;
		_postPosition = 0;
		_currentPost = null;
	}
	
	/**
	 * Stores a post to the sequence.
	 * @param	pInput Post to store.
	 */
	public function storePost(pInput:PxInputPost):Void 
	{
		if (_currentPost == null) 
		{
			_currentPost = pInput;
			_posts.push(_currentPost);
		} 
		else 
		{
			if (_currentPost.equals(pInput)) 
			{
				_currentPost.duration++;
			} 
			else 
			{
				_currentPost = pInput;
				_posts.push(_currentPost);
			}
		}
	}
	
	/**
	 * Fetches the next post in the queue.
	 * @return	The next post in line.
	 */
	public function fetchPost():PxInputPost 
	{
		if (_currentPost == null) 
		{
			_currentPost = _posts[_position];
		} 
		else 
		{
			_postPosition++;
			
			if (_postPosition > _currentPost.duration) 
			{
				_postPosition = 0;
				_position++;
				_currentPost = _posts[_position];
			}
		}
		
		return _currentPost;
	}
	
	/**
	 * Returns a string representation of the sequence.
	 * @return	String representation of the sequence
	 */
	public function toString():String 
	{
		var s:String = "";
		for (p in _posts) 
		{
			s += p.toString() + ":";
		}
		
		// lose the last ':'
		s = s.substr(0, s.length - 1);
		
		return s;
	}
	
	/**
	 * Populates the sequence using data from toString().
	 * Restars the sequence.
	 * @param	pData	Data to populate with.
	 */
	public function fromString(pData:String):Void 
	{
		reset();
		
		var posts:Array<String> = pData.split(":");
		
		for (data in posts) 
		{
			if (data.length > 0) 
			{
				var post:PxInputPost = new PxInputPost();
				post.fromString(data);
				storePost(post);
			}
		}
		restart();
	}	

}