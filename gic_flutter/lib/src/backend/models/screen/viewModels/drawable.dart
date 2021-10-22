class Drawable {
    final _value;
    const Drawable._internal(this._value);
    toString() => _value;

    static const Drawable button_neon = Drawable._internal("button_neon");
}