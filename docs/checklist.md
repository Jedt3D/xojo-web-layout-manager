# FlexLayoutManager Test Checklist

Use this checklist to verify that the `FlexLayoutManager` Xojo Web port functions correctly according to the original desktop specification.

## 1. Basic Configuration
- [ ] Manager can be instantiated without errors.
- [ ] Controls can be added using `AddControl(control, growFactor)`.
- [ ] `ApplyLayout()` runs without errors when no controls are added.
- [ ] Invisible controls (`Visible = False`) are ignored during layout calculations.
- [ ] `SetFlexGrow(control, factor)` correctly updates an item's grow factor.

## 2. Flex Direction
- [ ] **Row (`Direction = 0`)**: Controls are placed horizontally left-to-right.
- [ ] **Column (`Direction = 1`)**: Controls are placed vertically top-to-bottom.

## 3. Flex Grow
- [ ] Items with `GrowFactor = 0` maintain their initial fixed Width/Height.
- [ ] Items with `GrowFactor > 0` expand to fill remaining space along the main axis.
- [ ] Multiple growing items divide remaining space proportionally (e.g., Factor 1 vs Factor 2 gives 1/3 and 2/3 of remaining space).
- [ ] If remaining space is negative or 0, growing items size appropriately (do not become negatively sized).
- [ ] **Mixed grow factors (first=0, rest>0)**: When the first control has `GrowFactor = 0` and subsequent controls have `GrowFactor > 0`, grow>0 controls correctly share remaining space and grow=0 controls keep their original size. Verify in both Row and Column directions.
- [ ] **Mixed grow factors with Justify=Stretch**: Same scenario as above but with `Justify = Stretch`. The grow=0 control must retain its basis size, not the stretched size from an intermediate layout pass.

## 4. Justify Content (Main Axis Alignment)
*Test these with `GrowFactor = 0` on all items, otherwise FlexGrow overrides JustifyContent.*
- [ ] **FlexStart**: Items are clustered at the beginning of the container (left for Row, top for Column).
- [ ] **FlexEnd**: Items are clustered at the end of the container (right for Row, bottom for Column).
- [ ] **Center**: Items are clustered together in the center of the main axis.
- [ ] **SpaceBetween**: First item is at the start, last item is at the end, remaining space is evenly divided between items.
- [ ] **SpaceAround**: Space is evenly distributed around all items (half-size gap at the ends).
- [ ] **Stretch**: All items are resized equally to fill the available main axis space exactly.

## 5. Align Items (Cross Axis Alignment)
- [ ] **FlexStart**: Items are aligned to the top (for Row) or left (for Column) of the container.
- [ ] **FlexEnd**: Items are aligned to the bottom (for Row) or right (for Column) of the container.
- [ ] **Center**: Items are vertically centered (for Row) or horizontally centered (for Column).
- [ ] **Stretch**: Items are resized along the cross axis to fill the entire container height (for Row) or width (for Column).

## 6. Spacing and Padding
- [ ] **Gap**: The specified pixel distance is maintained strictly between adjacent items.
- [ ] **PaddingLeft/Right**: Controls never breach the left/right padding boundaries of the container.
- [ ] **PaddingTop/Bottom**: Controls never breach the top/bottom padding boundaries of the container.
- [ ] Container resizing calculates available space strictly inside the defined padding.

## 7. Dynamic Updates & Edge Cases
- [ ] Calling `ApplyLayout()` after resizing the browser/container updates all positions correctly.
- [ ] Calling `ApplyLayout()` after changing a control's visibility recalculates the layout correctly, filling the gap of the hidden control.
- [ ] Extremely small container sizes don't crash the algorithm or result in negative dimensions.
- [ ] Floating-point precision during FlexGrow distribution doesn't leave gaps or cause items to overflow bounds.
