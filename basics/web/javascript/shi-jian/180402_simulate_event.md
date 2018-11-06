# 模拟事件

## click

`elem.click()`

## dispatchEvent

用于分发自定义事件，可以配合`document.createEvent`和`new CustomEvent`使用

```javascript
elem.dispatchEvent(eventObject) // created by createEvent or new CustomEvent
```

### createEvent

```javascript
function dispatch(el, etype){
  if (el.fireEvent) {
    el.fireEvent('on' + etype);
  } else {
    var evObj = document.createEvent('Events');
    evObj.initEvent(etype, true, false);
    el.dispatchEvent(evObj);
  }
}
```

### CustomEvent\(\) Constructor

> [doc](https://developer.mozilla.org/en-US/docs/Web/API/CustomEvent)

```javascript
var e = new CustomEvent('click', { bubbles: false });
elem.dispatchEvent(e);
```

## Usage

### keyboardEvent

```javascript
var keyboardEvent = document.createEvent("KeyboardEvent");
var initMethod = typeof keyboardEvent.initKeyboardEvent !== 'undefined' ? "initKeyboardEvent" : "initKeyEvent";


keyboardEvent[initMethod](
                   "keydown", // event type : keydown, keyup, keypress
                    true, // bubbles
                    true, // cancelable
                    window, // viewArg: should be window
                    false, // ctrlKeyArg
                    false, // altKeyArg
                    false, // shiftKeyArg
                    false, // metaKeyArg
                    40, // keyCodeArg : unsigned long the virtual key code, else 0
                    0 // charCodeArgs : unsigned long the Unicode character associated with the depressed key, else 0
);
document.dispatchEvent(keyboardEvent);
```

