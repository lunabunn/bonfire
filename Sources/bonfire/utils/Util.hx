package bonfire.utils;

class Util {
    /**
     * Returns `value` unless it is null, in which case `fallback` is returned instead.
     * @param value The regular value
     * @param fallback The value to fall back to if the regular value is null
     */
    public static inline function fallback<T>(value: Null<T>, fallback: T) {
        if (value == null) return fallback;
        return value;
    }
}