```html
<div class="fl w-10 h-auto">
  <img class="br-100" src="{{ item?.owner.avatarUrl }}" />
</div>
<div class="fl w-90 ph3">
  <h1 class="f5 ma0">{{ item.fullName }}</h1>
  <p>
    <a href="{{ item?.htmlUrl }}" class="light-blue" target="_blank"
      >{{ item?.htmlUrl }}</a
    >
  </p>
</div>
```
