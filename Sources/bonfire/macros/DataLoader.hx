package bonfire.macros;

import haxe.Json;
import haxe.macro.Context;
import haxe.macro.Expr.Field;
import bonfire.utils.Util;
#if macro
import sys.io.File;
#end

class DataLoader {
    macro public static function build(): Array<Field> {
        var fields = Context.getBuildFields();
        var data: Dynamic;
        try {
            data = Json.parse(File.getContent("../") + (Context.defined("dataJson")? Context.definedValue("dataJson"):"data.json"));
        } catch (error: String) {
            data = {};
        }
        fields.push({
            name: "TITLE",
            access: [AStatic, APublic, AInline],
            kind: FVar(macro: String, macro $v{Util.fallback(data.title, "New Project")}),
            doc: "A string representing the title of the game.",
            pos: Context.currentPos()
        });
        fields.push({
            name: "WIDTH",
            access: [AStatic, APublic, AInline],
            kind: FVar(macro: Int, macro $v{Util.fallback(data.width, 544)}),
            doc: "An integer value representing the width of the game's viewport.",
            pos: Context.currentPos()
        });
        fields.push({
            name: "HEIGHT",
            access: [AStatic, APublic, AInline],
            kind: FVar(macro: Int, macro $v{Util.fallback(data.height, 416)}),
            doc: "An integer value representing the height of the game's viewport.",
            pos: Context.currentPos()
        });
        fields.push({
            name: "WINDOW_WIDTH",
            access: [AStatic, APublic, AInline],
            kind: FVar(macro: Int, macro $v{Util.fallback(data.width, 1088)}),
            doc: "An integer value representing the initial width of the game window. Note that this value isn't updated on window resize; use `window.width` if you need the actual width of the game window.",
            pos: Context.currentPos()
        });
        fields.push({
            name: "WINDOW_HEIGHT",
            access: [AStatic, APublic, AInline],
            kind: FVar(macro: Int, macro $v{Util.fallback(data.height, 832)}),
            doc: "An integer value representing the initial height of the game window. Note that this value isn't updated on window resize; use `window.height` if you need the actual height of the game window.",
            pos: Context.currentPos()
        });
        fields.push({
            name: "FULLSCREEN",
            access: [AStatic, APublic, AInline],
            kind: FVar(macro: Bool, macro $v{Util.fallback(data.fullscreen, false)}),
            doc: "A boolean value representing whether or not to start the game in fullscreen mode. To check if the game is currently running in fullscreen mode, use `window.mode == kha.WindowMode.Fullscreen`.",
            pos: Context.currentPos()
        });
        fields.push({
            name: "ASPECT_RATIO",
            access: [AStatic, APublic, AInline],
            kind: FVar(macro: Float, macro $v{Util.fallback(data.width, 544) / Util.fallback(data.height, 416)}),
            doc: "A float value representing the ratio between the width and height of the game's viewport.",
            pos: Context.currentPos()
        });
        fields.push({
            name: "FPS",
            access: [AStatic, APublic, AInline],
            kind: FVar(macro: Int, macro $v{Util.fallback(data.fps, 60)}),
            doc: "An integer value representing the target frames per second. Note that this value may not always be the same as the actual number of frames per second.",
            pos: Context.currentPos()
        });
        return fields;
    }
}