package bonfire;

import kha.input.Keyboard;
import kha.WindowMode;
import kha.Image;
import kha.Window;
import kha.Assets;
import kha.Framebuffer;
import kha.Scheduler;
import kha.System;

@:build(bonfire.macros.DataLoader.build())
class Game {
	static var windowWidthPrev: Int = WINDOW_WIDTH;
	static var windowHeightPrev: Int = WINDOW_HEIGHT;
	static var timePrev: Float = 0;

	/**
	 * A Kha Window instance that represents the game window.
	 */
	public static var window(default, null): Window;

	static var backbuffer: Image;
	static var dx: Float = 0;
	static var dy: Float = 0;
	static var dw: Float = WINDOW_WIDTH;
	static var dh: Float = WINDOW_HEIGHT;

	static function init(): Void {
        
	}

	static function update(dt: Float): Void {
		if (window.width != windowWidthPrev
			|| window.height != windowHeightPrev) {
			resize(window.width, window.height);
			windowWidthPrev = window.width;
			windowHeightPrev = window.height;
		}

        Input.update();
	}

	static function render(frame: Framebuffer): Void {
        // Render on "back buffer" first
		backbuffer.g2.begin();
		backbuffer.g2.end();

        // Draw scaled back buffer on "front buffer" (frame buffer)
		frame.g2.begin();
		frame.g2.drawScaledImage(backbuffer, dx, dy, dw, dh);
		frame.g2.end();
	}
    
	static function resize(w: Int, h: Int) {
		var screenRatio: Float = w / h;
		if (screenRatio > ASPECT_RATIO) {
			dw = ASPECT_RATIO * h;
			dh = h;
			dx = (w - dw) / 2;
			dy = 0;
		} else if (screenRatio < ASPECT_RATIO) {
			dw = w;
			dh = w / ASPECT_RATIO;
			dx = 0;
			dy = (h - dh) / 2;
		} else {
			dw = w;
			dh = h;
			dx = 0;
			dy = 0;
		}
	}

	/**
	 * Starts the game.
	 */
	public static function start(): Void {
		System.start({title: TITLE, width: WINDOW_WIDTH, height: WINDOW_HEIGHT}, function (_) {
            window = _;
            window.visible = false;
            if (FULLSCREEN) window.mode = WindowMode.Fullscreen;
			Assets.loadEverything(function () {
				backbuffer = Image.createRenderTarget(WIDTH, HEIGHT);
				init();
                window.visible = true;
				Scheduler.addTimeTask(function () {
					var time = Scheduler.time();
					update((time - timePrev) * FPS);
					timePrev = time;
				}, 0, 1 / FPS);
				System.notifyOnFrames(function (frames) {
					render(frames[0]);
				});

                Input.initKeyboard(Keyboard.get());
			});
		});
	}
}
