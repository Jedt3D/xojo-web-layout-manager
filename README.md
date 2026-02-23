# WebFlexLayoutManager

`WebFlexLayoutManager` is a custom layout manager component for Xojo Web, designed to bring CSS Flexbox-like layout capabilities natively to Xojo Web controls. It is a direct port from a Desktop version, allowing developers to create responsive, dynamic layouts without needing to write custom CSS or JavaScript.

The main idea behind `WebFlexLayoutManager` is to allow Xojo Web UI controls to be automatically positioned and sized according to flexbox rules (Row/Column direction, alignment, justification, growing, and gap spacing), recalculating positions automatically on browser resize or control visibility changes.

## Features

- **Flexbox-like Algorithm**: Implements a subset of CSS Flexbox logic directly in Xojo code.
- **Direction Support**: Arrange controls in a `Row` (horizontal) or `Column` (vertical).
- **Justify Content (Main Axis)**: Support for `FlexStart`, `FlexEnd`, `Center`, `SpaceBetween`, `SpaceAround`, and `Stretch`.
- **Align Items (Cross Axis)**: Support for `FlexStart`, `FlexEnd`, `Center`, and `Stretch`.
- **Flex Grow**: Controls can be assigned a grow factor (via `AddControl(control, growFactor)` or `SetFlexGrow(control, factor)`) to proportionally share remaining available space.
- **Spacing Control**: Define a specific pixel `Gap` between items.
- **Padding Boundaries**: Supports `PaddingLeft`, `PaddingRight`, `PaddingTop`, and `PaddingBottom` for the container.
- **Dynamic Updates**: Automatically recalculates layout when the browser window is resized (via `Resized` event) or when control properties are updated.
- **Visibility Handling**: Automatically ignores invisible controls (`Visible = False`) and recalculates the layout for remaining visible items.

## Suggested New Features

- **Flex Wrap**: Support wrapping controls to a new line/column when they exceed the available container space.
- **Flex Basis**: Allow defining a base size for items before remaining space is distributed.
- **Align Self**: Allow individual controls to override the container's `AlignItems` property.
- **Nested Layouts Support**: Improve support and testing for placing `WebFlexLayoutManager` instances inside other `WebFlexLayoutManager` instances.
- **Max/Min Constraints**: Respect minimum and maximum width/height constraints of managed controls during layout calculation.

## Changelog & Implementation Notes

### Initial Port & Implementation
**Problem**: Xojo Web controls rely on absolute positioning or basic locking, making complex responsive layouts difficult without writing custom WebSDK controls or injecting raw CSS.
**Solution**: Ported the desktop FlexLayoutManager to Xojo Web by subclassing `WebRectangle`. Implemented a 5-step mathematical layout algorithm entirely in Xojo code to calculate absolute `Left`, `Top`, `Width`, and `Height` properties for child controls.

### Handling Window Resizing
**Problem**: The layout needs to update automatically when the browser window changes size.
**Solution**: Utilized the `WebRectangle.Resized` event to trigger `ApplyLayout()`.

### Initial Layout Rendering Issue
**Problem**: Sometimes the layout wouldn't apply correctly on initial page load because control dimensions weren't fully realized by the browser.
**Solution**: Added a JavaScript workaround in the `Shown` event: `Me.ExecuteJavaScript("setTimeout(function(){ window.dispatchEvent(new Event('resize')); }, 50);")` to force a resize event shortly after the control is rendered on the client side.

### Flex Grow Precision
**Problem**: Distributing fractional remaining space among multiple growing controls could leave empty gaps due to integer rounding.
**Solution**: Implemented a floating-point calculation `Round((grow / totalFlexGrow) * remainingSpace)` to minimize rounding errors during distribution.
