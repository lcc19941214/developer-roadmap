# antd 1.x datepicker 时区问题

Antd\(1.x stable\) - [DatePicker](https://github.com/ant-design/ant-design/blob/1.x-stable/components/date-picker/index.jsx)

## 依赖关系

* 底层引用了 [rc-calender](https://github.com/react-component/calendar/blob/5.6.2/src/index.js)\(~5.6.2\)
* [封装过程](https://github.com/ant-design/ant-design/blob/1.x-stable/components/date-picker/index.jsx#L8)中使用了`wrapPicker`方法和`createPicker`方法

  ```javascript
  const DatePicker = wrapPicker(createPicker(RcCalendar));
  const MonthPicker = wrapPicker(createPicker(MonthCalendar), 'yyyy-MM');
  ```

* DatePicker的Date处理函数，依赖[gregorian-calendar（4.1.0）](https://github.com/yiminghe/gregorian-calendar/blob/4.1.0/src/gregorian-calendar.js)
* `gregorian-calendar`内置了[en\_US](https://github.com/yiminghe/gregorian-calendar/blob/4.1.0/src/locale/en_US.js)和[zh\_CN](https://github.com/yiminghe/gregorian-calendar/blob/4.1.0/src/locale/zh_CN.js)两个locale配置文件，内置的时间处理对象`GregorianCalendar`[默认使用en\_US](https://github.com/yiminghe/gregorian-calendar/blob/4.1.0/src/gregorian-calendar.js#L8).

  antd全局以及各组件配置了不同的locale，分别处理不同的场景，但是DatePicker最底层是直接使用了`gregorian-calendar`中的配置

  ```javascript
  /*
   * en-us locale
   * @ignore
   * @author yiminghe@gmail.com
   */
  module.exports = {
    // in minutes
    timezoneOffset: -8 * 60,
    firstDayOfWeek: 0,
    minimalDaysInFirstWeek: 1,
  };
  ```

  ```javascript
  /*
   * zh-cn locale
   * @ignore
   * @author yiminghe@gmail.com
   */
  module.exports = {
    // in minutes
    timezoneOffset: 8 * 60,
    firstDayOfWeek: 1,
    minimalDaysInFirstWeek: 1,
  };
  ```

## 代码逻辑分析

* `wrapPicker`方法默认传递一些参数给`createPicker`，[默认传入zh\_CN](https://github.com/ant-design/ant-design/blob/1.x-stable/components/date-picker/wrapPicker.jsx#L6)。同时会从antd的全局locale方法中寻找DatePicker的locale配置

  ```javascript
  getLocale() {
    const props = this.props;
    let locale = defaultLocale;
    const context = this.context;
    if (context.antLocale && context.antLocale.DatePicker) {
      locale = context.antLocale.DatePicker;
    }
    // 统一合并为完整的 Locale
    const result = { ...locale, ...props.locale };
    result.lang = { ...locale.lang, ...props.locale.lang };
    return result;
  }
  ```

* `createPicker`将props传入的`locale`，传递给`GregorianCalendar`对象生成基本的locale信息

  ```javascript
  const props = this.props;
  const locale = props.locale;
  // 以下两行代码
  // 给没有初始值的日期选择框提供本地化信息
  // 否则会以周日开始排
  let defaultCalendarValue = new GregorianCalendar(locale);
  defaultCalendarValue.setTime(Date.now());
  ```

* rc-calender根据locale信息进行组件渲染

  ```javascript
  <TheCalendar
    ...
    formatter={props.getFormatter()}
    locale={locale.lang}
    ... />
  ```

## 核心问题

* 1.x 的antd datepick在使用时，不根据用户的`new Date().timezoneOffset`设置日期，而是根据默认的local配置进行设置。分析过程见上述“代码逻辑分析”
* 外层的antd的LocaleProvider包装组件会修改全局的locale，因此双语切换时，会存在用户的datepicker组件时区被改写的问题

## 解决方案

* `wrapPicker`方法中会从全局的`antLocale.DatePicker` locale配置，将此处的timezoneOffset覆写即可

  ```javascript
  // wrapPicker.jsx中寻找DatePicker local而配置的判断逻辑
  if (context.antLocale && context.antLocale.DatePicker) {
    locale = context.antLocale.DatePicker;
  }
  ```

### 深入LocaleProvider的配置

`LocaleProvider`的使用

```javascript
import enUS from 'antd/lib/locale-provider/en_US';

...

return <LocaleProvider locale={enUS}><App /></LocaleProvider>;
```

`locale`的配置，以`en_US`为例

```javascript
// antd/lib/locale-provider/en_US
import DatePicker from '../date-picker/locale/en_US';
import TimePicker from '../time-picker/locale/en_US';

export default {
  ...
  DatePicker,
  TimePicker,
  ...
}; 


// date-picker/locale/en_US
import GregorianCalendarLocale from 'gregorian-calendar/lib/locale/en_US';
import CalendarLocale from 'rc-calendar/lib/locale/en_US';
import TimePickerLocale from '../../time-picker/locale/en_US';

// 统一合并为完整的 Locale
const locale = { ...GregorianCalendarLocale };
locale.lang = {
  placeholder: 'Select date',
  rangePlaceholder: ['Start date', 'End date'],
  ...CalendarLocale, // 因为这里不包含timezoneOffset，就不展示这部分的内容了
};

locale.timePickerLocale = { ...TimePickerLocale };

export default locale;
```

