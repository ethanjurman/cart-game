package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;

class Player extends FlxSprite
{
	static inline var SPEED:Float = 30;
	static inline var INITIAL_DRAG:Float = 1600;

	public var playerCartDirection:String = "horizontal";
	public var playerShootingDirection:String = "right";
	public var playerCartOrientation:Int = 0;
	public var playerIsTurning:Bool = false;
	public var playerHasTurned:Bool = false;

	// while not required, we're saving all of these so we can verify
	// later (before failing to load it) if we have the animation key
	var possibleAnimationKeys:Array<String> = new Array<String>();

	// constructor for a new player
	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);

		// for now, always facing up, to fix later
		facing = FlxObject.UP;

		// use an animation instead of a simple graphic
		loadGraphic(AssetPaths.link_ooa_cart_shooting__png, true, 17, 23);
		buildPlayerAnimations();

		drag.x = drag.y = INITIAL_DRAG;

		// set the character sprite to just be the cart
		setSize(16, 16);
		offset.set(0, 22 - 16);
	}

	override function update(elapsed:Float)
	{
		updateAcceleration(); // call our Acceleration helper function
		updatePlayerDirection(); // call our function for direction pointing
		updatePlayerAnimation(); // call our function to update the animation based on player props

		// cursor debugging
		// var sprite = new FlxSprite();
		// sprite.makeGraphic(15, 15, FlxColor.TRANSPARENT);
		// FlxG.mouse.load(sprite.pixels);

		// x = FlxG.mouse.x;
		// y = FlxG.mouse.y;

		super.update(elapsed);
	}

	public function setCartDirection(newCartDirection:String)
	{
		playerCartDirection = newCartDirection;
	}

	// function to mark the player as turning
	// they shouldn't be able to do other actions here
	public function startTurning()
	{
		playerIsTurning = true;
		playerHasTurned = false;
	}

	public function turn()
	{
		playerIsTurning = true;
		playerHasTurned = true;
	}

	public function finishTurning()
	{
		playerIsTurning = false;
		playerHasTurned = false;
	}

	public function rotatePlayer(rotation:String)
	{
		if (rotation == "clockwise")
			playerCartOrientation = (playerCartOrientation + 90) % 360;
		else if (rotation == "counterclockwise")
			playerCartOrientation = (playerCartOrientation - 90) % 360;

		if (playerCartDirection == "vertical")
			playerCartDirection = "horizontal";
		else
			playerCartDirection = "vertical";
	}

	function updatePlayerDirection()
	{
		playerShootingDirection = null;

		// check which keys are pressed (up or down)
		if (FlxG.keys.anyPressed([UP, W]))
			playerShootingDirection += "up";
		else if (FlxG.keys.anyPressed([DOWN, S]))
			playerShootingDirection += "down";

		// check which keys are pressed (left or right)
		if (FlxG.keys.anyPressed([LEFT, A]))
			playerShootingDirection += "left";
		else if (FlxG.keys.anyPressed([RIGHT, D]))
			playerShootingDirection += "right";

		// if the shooting direction is still null, set it to right
		playerShootingDirection = "right";
	}

	// helper function to add all the animations that are possible with the sprite sheet
	function buildPlayerAnimations()
	{
		// set the animations for our player based on the sprite sheet
		var cartDirections:Array<String> = ["vertical", "horizontal"];
		var playerDirections:Array<String> = [
			"downleft",
			"down",
			"upright",
			"up",
			"downright",
			"upleft",
			"left",
			"unused",
			"right"
		];
		for (cartDirection in cartDirections)
		{
			for (playerDirection in playerDirections)
			{
				var frames:Array<Int> = getSpriteAnimationFrames(cartDirection, playerDirection);
				var animationKey = cartDirection + "_cart_facing_" + playerDirection;
				animation.add(animationKey, frames, 6, true);
				possibleAnimationKeys.push(animationKey);
			}
		}
	}

	// helper function to parse which frames to load from the sprite
	function getSpriteAnimationFrames(cartDirection:String, playerDirection:String)
	{
		var firstFrame:Int = 0;

		// the second set of sprites are the horizontal cart frames
		if (cartDirection == "horizontal")
			firstFrame += 18;

		// make an array of all the different positions, and we'll just indexOf it to get which one we need
		// this is based on the sprite sheet, this needs to change if "link_ooa_cart_shooting.png" changes.
		var positionsInSheet:Array<String> = [
			"downleft",
			"down",
			"upright",
			"up",
			"downright",
			"upleft",
			"left",
			"unused",
			"right"
		];

		firstFrame += (positionsInSheet.indexOf(playerDirection) * 2);

		return [firstFrame, firstFrame + 1];
	}

	// helper function for Acceleration
	function updateAcceleration()
	{
		var accelerating:Bool = false;

		accelerating = FlxG.keys.anyPressed([SPACE]);

		// determine the new speed
		var newSpeed:Float = if (accelerating) SPEED * 2 else SPEED;

		// set the velocity
		velocity.set(newSpeed, 0);

		velocity.rotate(FlxPoint.weak(0, 0), playerCartOrientation);
	}

	// helper function for testing facing directions
	function updatePlayerAnimation()
	{
		var animationKey = playerCartDirection + "_cart_facing_" + playerShootingDirection;
		if (possibleAnimationKeys.contains(animationKey))
		{
			animation.play(animationKey);
		}
	}
}