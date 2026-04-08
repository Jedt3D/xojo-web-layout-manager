#tag Class
Protected Class WebFlexLayoutManager
Inherits WebRectangle
	#tag Event
		Sub Resized()
		  ApplyLayout()
		End Sub
	#tag EndEvent

	#tag Event
		Sub Shown()
		  Me.ExecuteJavaScript("setTimeout(function(){ window.dispatchEvent(new Event('resize')); }, 50);")
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		Sub AddControl(c As WebUIControl, growFactor As Double = 0)
		  If c = Nil Then Return

		  System.DebugLog("FlexLayoutManager: Adding control " + c.Name + " with growFactor " + Str(growFactor))

		  ManagedControls.Add(c)
		  FlexGrowMap.Value(c) = growFactor
		  BasisWidthMap.Value(c) = c.Width
		  BasisHeightMap.Value(c) = c.Height

		  ApplyLayout()
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ApplyLayout()
		  If ManagedControls.LastIndex < 0 Then Return
		  
		  // Step 1: Gather visible controls and metrics
		  Var visibleControls() As WebUIControl
		  Var totalFlexGrow As Double = 0
		  Var totalFixedSpace As Integer = 0
		  
		  For Each c As WebUIControl In ManagedControls
		    If c.Visible Then
		      visibleControls.Add(c)
		      
		      Var grow As Double = 0
		      If FlexGrowMap.HasKey(c) Then
		        grow = FlexGrowMap.Value(c)
		      End If
		      
		      totalFlexGrow = totalFlexGrow + grow
		      
		      If grow = 0 Then
		        If Direction = FlexDirection.Row Then
		          totalFixedSpace = totalFixedSpace + BasisWidthMap.Value(c).IntegerValue
		        Else
		          totalFixedSpace = totalFixedSpace + BasisHeightMap.Value(c).IntegerValue
		        End If
		      End If
		    End If
		  Next
		  
		  If visibleControls.LastIndex < 0 Then Return
		  
		  // Step 2: Calculate available space
		  Var availableMainSpace As Integer
		  Var availableCrossSpace As Integer
		  
		  If Direction = FlexDirection.Row Then
		    availableMainSpace = Me.Width - PaddingLeft - PaddingRight
		    availableCrossSpace = Me.Height - PaddingTop - PaddingBottom
		  Else
		    availableMainSpace = Me.Height - PaddingTop - PaddingBottom
		    availableCrossSpace = Me.Width - PaddingLeft - PaddingRight
		  End If
		  
		  If availableMainSpace < 0 Then availableMainSpace = 0
		  If availableCrossSpace < 0 Then availableCrossSpace = 0
		  
		  Var totalGapSpace As Integer = 0
		  If visibleControls.Count > 1 Then
		    totalGapSpace = (visibleControls.Count - 1) * Gap
		  End If
		  Var remainingSpace As Integer = availableMainSpace - totalFixedSpace - totalGapSpace
		  If remainingSpace < 0 Then remainingSpace = 0
		  
		  // Step 3: Calculate main-axis sizes (flex grow distribution)
		  Var mainSizes() As Integer
		  Var totalUsedSpace As Integer = totalGapSpace
		  
		  If Justify = JustifyContent.Stretch And totalFlexGrow = 0 Then
		    // Stretch with no flex grow: distribute space equally to all controls
		    Var stretchSize As Integer = 0
		    If visibleControls.Count > 0 Then
		      stretchSize = Round((availableMainSpace - totalGapSpace) / visibleControls.Count)
		      If stretchSize < 0 Then stretchSize = 0
		    End If
		    For Each c As WebUIControl In visibleControls
		      mainSizes.Add(stretchSize)
		      totalUsedSpace = totalUsedSpace + stretchSize
		    Next
		  Else
		    For Each c As WebUIControl In visibleControls
		      Var size As Integer
		      Var grow As Double = 0
		      If FlexGrowMap.HasKey(c) Then
		        grow = FlexGrowMap.Value(c)
		      End If
		      
		      If grow > 0 And totalFlexGrow > 0 Then
		        size = Round((grow / totalFlexGrow) * remainingSpace)
		      Else
		        If Direction = FlexDirection.Row Then
		          size = BasisWidthMap.Value(c).IntegerValue
		        Else
		          size = BasisHeightMap.Value(c).IntegerValue
		        End If
		      End If
		      
		      mainSizes.Add(size)
		      totalUsedSpace = totalUsedSpace + size
		    Next
		  End If
		  
		  // Step 4: Apply Justify Content (main axis starting position and gap adjustment)
		  Var currentMainPos As Double
		  Var actualGap As Double = Gap
		  
		  If Justify = JustifyContent.Stretch And totalFlexGrow = 0 Then
		    // Stretch: already sized in Step 3, just set starting position
		    If Direction = FlexDirection.Row Then
		      currentMainPos = PaddingLeft
		    Else
		      currentMainPos = PaddingTop
		    End If
		  ElseIf totalFlexGrow = 0 Then
		    Select Case Justify
		    Case JustifyContent.FlexStart
		      If Direction = FlexDirection.Row Then
		        currentMainPos = PaddingLeft
		      Else
		        currentMainPos = PaddingTop
		      End If
		      
		    Case JustifyContent.FlexEnd
		      Var totalItemsAndGaps As Integer = totalFixedSpace + totalGapSpace
		      Var startOffset As Integer = availableMainSpace - totalItemsAndGaps
		      If Direction = FlexDirection.Row Then
		        currentMainPos = PaddingLeft + startOffset
		      Else
		        currentMainPos = PaddingTop + startOffset
		      End If
		      
		    Case JustifyContent.Center
		      Var totalItemsAndGaps As Integer = totalFixedSpace + totalGapSpace
		      Var startOffset As Double = (availableMainSpace - totalItemsAndGaps) / 2.0
		      If startOffset < 0 Then startOffset = 0
		      If Direction = FlexDirection.Row Then
		        currentMainPos = PaddingLeft + startOffset
		      Else
		        currentMainPos = PaddingTop + startOffset
		      End If
		      
		    Case JustifyContent.SpaceBetween
		      If Direction = FlexDirection.Row Then
		        currentMainPos = PaddingLeft
		      Else
		        currentMainPos = PaddingTop
		      End If
		      If visibleControls.Count > 1 Then
		        actualGap = (availableMainSpace - totalFixedSpace) / (visibleControls.Count - 1)
		        If actualGap < 0 Then actualGap = 0
		      End If
		      
		    Case JustifyContent.SpaceAround
		      Var spacePerItem As Double = (availableMainSpace - totalFixedSpace) / visibleControls.Count
		      If spacePerItem < 0 Then spacePerItem = 0
		      actualGap = spacePerItem
		      If Direction = FlexDirection.Row Then
		        currentMainPos = PaddingLeft + (spacePerItem / 2.0)
		      Else
		        currentMainPos = PaddingTop + (spacePerItem / 2.0)
		      End If
		    End Select
		  Else
		    // Flex grow items fill the space, start at beginning
		    If Direction = FlexDirection.Row Then
		      currentMainPos = PaddingLeft
		    Else
		      currentMainPos = PaddingTop
		    End If
		  End If
		  
		  // Step 5: Position each control (main axis + cross axis alignment)
		  For i As Integer = 0 To visibleControls.LastIndex
		    Var c As WebUIControl = visibleControls(i)
		    Var mainSize As Integer = mainSizes(i)
		    Var crossPos As Integer
		    Var crossSize As Integer
		    
		    If Direction = FlexDirection.Row Then
		      crossSize = c.Height
		    Else
		      crossSize = c.Width
		    End If
		    
		    Select Case Align
		    Case AlignItems.FlexStart
		      If Direction = FlexDirection.Row Then
		        crossPos = PaddingTop
		      Else
		        crossPos = PaddingLeft
		      End If
		      
		    Case AlignItems.FlexEnd
		      If Direction = FlexDirection.Row Then
		        crossPos = Me.Height - PaddingBottom - crossSize
		      Else
		        crossPos = Me.Width - PaddingRight - crossSize
		      End If
		      
		    Case AlignItems.Center
		      If Direction = FlexDirection.Row Then
		        crossPos = PaddingTop + Round((availableCrossSpace - crossSize) / 2.0)
		      Else
		        crossPos = PaddingLeft + Round((availableCrossSpace - crossSize) / 2.0)
		      End If
		      
		    Case AlignItems.Stretch
		      If Direction = FlexDirection.Row Then
		        crossPos = PaddingTop
		        crossSize = availableCrossSpace
		      Else
		        crossPos = PaddingLeft
		        crossSize = availableCrossSpace
		      End If
		    End Select
		    
		    // Apply position and size to control
		    If Direction = FlexDirection.Row Then
		      c.Left = Round(currentMainPos)
		      c.Top = crossPos
		      c.Width = mainSize
		      c.Height = crossSize
		    Else
		      c.Left = crossPos
		      c.Top = Round(currentMainPos)
		      c.Width = crossSize
		      c.Height = mainSize
		    End If
		    
		    currentMainPos = currentMainPos + mainSize + actualGap
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor()
		  // Calling the overridden superclass constructor.
		  Super.Constructor

		  FlexGrowMap = New Dictionary
		  BasisWidthMap = New Dictionary
		  BasisHeightMap = New Dictionary
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub RemoveAllControls()
		  ManagedControls.RemoveAll()
		  FlexGrowMap.Clear()
		  BasisWidthMap.Clear()
		  BasisHeightMap.Clear()
		  ApplyLayout()
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetFlexGrow(c As WebUIControl, growFactor As Double)
		  If c = Nil Then Return
		  
		  If FlexGrowMap.HasKey(c) Then
		    FlexGrowMap.Value(c) = growFactor
		    System.DebugLog("FlexLayoutManager: SetFlexGrow for " + c.Name + " to " + Str(growFactor))
		    ApplyLayout()
		  End If
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		Align As AlignItems = AlignItems.FlexStart
	#tag EndProperty

	#tag Property, Flags = &h0
		Direction As FlexDirection = FlexDirection.Row
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected BasisHeightMap As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected BasisWidthMap As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected FlexGrowMap As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h0
		Gap As Integer = 0
	#tag EndProperty

	#tag Property, Flags = &h0
		Justify As JustifyContent = JustifyContent.FlexStart
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected ManagedControls() As WebUIControl
	#tag EndProperty

	#tag Property, Flags = &h0
		PaddingBottom As Integer = 0
	#tag EndProperty

	#tag Property, Flags = &h0
		PaddingLeft As Integer = 0
	#tag EndProperty

	#tag Property, Flags = &h0
		PaddingRight As Integer = 0
	#tag EndProperty

	#tag Property, Flags = &h0
		PaddingTop As Integer = 0
	#tag EndProperty


	#tag Enum, Name = AlignItems, Type = Integer, Flags = &h0
		FlexStart = 0
		  FlexEnd = 1
		  Center = 2
		Stretch = 3
	#tag EndEnum

	#tag Enum, Name = FlexDirection, Type = Integer, Flags = &h0
		Row = 0
		Column = 1
	#tag EndEnum

	#tag Enum, Name = JustifyContent, Type = Integer, Flags = &h0
		FlexStart = 0
		  FlexEnd = 1
		  Center = 2
		  SpaceBetween = 3
		  SpaceAround = 4
		Stretch = 5
	#tag EndEnum


	#tag ViewBehavior
		#tag ViewProperty
			Name="LockHorizontal"
			Visible=true
			Group="Position"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockVertical"
			Visible=true
			Group="Position"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="PanelIndex"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="ControlCount"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="_mPanelIndex"
			Visible=false
			Group="Behavior"
			InitialValue="-1"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="_mDesignHeight"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="_mDesignWidth"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="ControlID"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Enabled"
			Visible=true
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="_mName"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="BorderColor"
			Visible=true
			Group="Behavior"
			InitialValue="&c000000FF"
			Type="ColorGroup"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="BorderThickness"
			Visible=true
			Group="Behavior"
			InitialValue="1"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="CornerSize"
			Visible=true
			Group="Behavior"
			InitialValue="-1"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="FillColor"
			Visible=true
			Group="Behavior"
			InitialValue="&cFFFFFF"
			Type="ColorGroup"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="HasFillColor"
			Visible=true
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="TabIndex"
			Visible=true
			Group="Visual Controls"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Indicator"
			Visible=false
			Group="Visual Controls"
			InitialValue=""
			Type="WebUIControl.Indicators"
			EditorType="Enum"
			#tag EnumValues
				"0 - Default"
				"1 - Primary"
				"2 - Secondary"
				"3 - Success"
				"4 - Danger"
				"5 - Warning"
				"6 - Info"
				"7 - Light"
				"8 - Dark"
				"9 - Link"
			#tag EndEnumValues
		#tag EndViewProperty
		#tag ViewProperty
			Name="Visible"
			Visible=true
			Group="Visual Controls"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LayoutType"
			Visible=true
			Group="WebView"
			InitialValue="LayoutTypes.Fixed"
			Type="LayoutTypes"
			EditorType="Enum"
			#tag EnumValues
				"0 - Fixed"
				"1 - Flex"
			#tag EndEnumValues
		#tag EndViewProperty
		#tag ViewProperty
			Name="LayoutDirection"
			Visible=true
			Group="WebView"
			InitialValue="LayoutDirections.LeftToRight"
			Type="LayoutDirections"
			EditorType="Enum"
			#tag EnumValues
				"0 - LeftToRight"
				"1 - RightToLeft"
				"2 - TopToBottom"
				"3 - BottomToTop"
			#tag EndEnumValues
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Width"
			Visible=true
			Group="Position"
			InitialValue="100"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Height"
			Visible=true
			Group="Position"
			InitialValue="100"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockLeft"
			Visible=true
			Group="Position"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockTop"
			Visible=true
			Group="Position"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockRight"
			Visible=true
			Group="Position"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockBottom"
			Visible=true
			Group="Position"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Direction"
			Visible=true
			Group="Behavior"
			InitialValue="0"
			Type="FlexDirection"
			EditorType="Enum"
			#tag EnumValues
				"0 - Row"
				"1 - Column"
			#tag EndEnumValues
		#tag EndViewProperty
		#tag ViewProperty
			Name="Justify"
			Visible=true
			Group="Behavior"
			InitialValue="0"
			Type="JustifyContent"
			EditorType="Enum"
			#tag EnumValues
				"0 - FlexStart"
				"1 - FlexEnd"
				"2 - Center"
				"3 - SpaceBetween"
				"4 - SpaceAround"
				"5 - Stretch"
			#tag EndEnumValues
		#tag EndViewProperty
		#tag ViewProperty
			Name="Align"
			Visible=true
			Group="Behavior"
			InitialValue="0"
			Type="AlignItems"
			EditorType="Enum"
			#tag EnumValues
				"0 - FlexStart"
				"1 - FlexEnd"
				"2 - Center"
				"3 - Stretch"
			#tag EndEnumValues
		#tag EndViewProperty
		#tag ViewProperty
			Name="Gap"
			Visible=true
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="PaddingLeft"
			Visible=true
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="PaddingTop"
			Visible=true
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="PaddingRight"
			Visible=true
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="PaddingBottom"
			Visible=true
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
