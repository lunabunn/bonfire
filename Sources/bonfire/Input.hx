package bonfire;

import kha.WindowMode;
import kha.input.Keyboard;
import kha.input.KeyCode;

class Input {
    static var keysDown = new Array<KeyCode>();
    static var keysPressed: Array<KeyCode>;
    static var keysReleased: Array<KeyCode>;

    static var addKeys = new Array<KeyCode>();
    static var removeKeys = new Array<KeyCode>();

    public static function update() {
        for (key in addKeys)
            if (keysDown.indexOf(key) == -1)
                keysDown.push(key);
        for (key in removeKeys)
            keysDown.remove(key);
        
        keysPressed = addKeys;
        keysReleased = removeKeys;
        addKeys = [];
        removeKeys = [];
    }

    public static inline function isDown(key: KeyCode) {
        return keysDown.indexOf(key) != -1;
    }

    public static inline function wasPressed(key: KeyCode) {
        if (keysPressed == null)
            return false;
        return keysPressed.indexOf(key) != -1;
    }

    public static inline function wasReleased(key: KeyCode) {
        if (keysReleased == null)
            return false;
        return keysReleased.indexOf(key) != -1;
    }

    public static function initKeyboard(keyboard: Keyboard) {
        keyboard.notify(onKeyDown, onKeyUp);
    }

    static function onKeyDown(key: KeyCode) {
        if (key == KeyCode.Return && Input.isDown(KeyCode.Alt)) {
            // TODO Fix this nonsense when https://github.com/Kode/Kha/pull/1158 is merged
            #if kha_html5
            if (@:privateAccess Game.window.isFullscreen())
                Game.window.mode = WindowMode.Windowed;
            else
                Game.window.mode = WindowMode.Fullscreen;
            #else
            if (Game.window.mode == WindowMode.Windowed)
                Game.window.mode = WindowMode.Fullscreen;
            else
                Game.window.mode = WindowMode.Windowed;
            #end
        }

        if (removeKeys.indexOf(key) != -1)
            removeKeys.remove(key);
        else if (addKeys.indexOf(key) == -1)
            addKeys.push(key);
    }

    static function onKeyUp(key: KeyCode) {
        if (addKeys.indexOf(key) != -1)
            addKeys.remove(key);
        else if (removeKeys.indexOf(key) == -1)
            removeKeys.push(key);
    }
}