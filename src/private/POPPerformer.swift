/*
 Copyright 2016-present The Material Motion Authors. All Rights Reserved.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import MaterialMotionRuntime
import pop

class POPPerformer: NSObject, PlanPerforming, ContinuousPerforming {
  let target: NSObject
  required init(target: Any) {
    self.target = target as! NSObject
  }

  var springs: [String: POPSpringAnimation] = [:]
  func addPlan(_ plan: Plan) {
    switch plan {
    case let springTo as SpringTo:
      self.addSpringTo(springTo)
    default:
      assertionFailure("Unknown plan: \(plan)")
    }
  }

  var tokens: [POPSpringAnimation: IsActiveTokenable] = [:]
  var tokenGenerator: IsActiveTokenGenerating!
  func set(isActiveTokenGenerator: IsActiveTokenGenerating) {
    tokenGenerator = isActiveTokenGenerator
  }
}

extension POPPerformer {
  fileprivate func springForProperty(_ property: POPProperty) -> POPSpringAnimation {
    let propertyName = property.name()
    if let existingAnimation = springs[propertyName] {
      return existingAnimation
    }

    let springAnimation = POPSpringAnimation(propertyNamed: propertyName)!

    springAnimation.dynamicsTension = SpringTo.defaultTension
    springAnimation.dynamicsFriction = SpringTo.defaultFriction
    springAnimation.delegate = self
    springAnimation.removedOnCompletion = false

    springs[propertyName] = springAnimation

    target.pop_add(springAnimation, forKey: nil)

    return springAnimation
  }
}

// MARK: SpringTo
extension POPPerformer {
  fileprivate func addSpringTo(_ springTo: SpringTo) {
    let springAnimation = springForProperty(springTo.property)
    if let configuration = springTo.configuration {
      springAnimation.dynamicsFriction = configuration.friction
      springAnimation.dynamicsTension = configuration.tension
    }
    springAnimation.toValue = springTo.destination
    springAnimation.isPaused = false
  }
}

extension POPPerformer {
  func pop_animationDidStart(_ anim: POPSpringAnimation!) {
    guard let token = tokenGenerator.generate() else { return }
    tokens[anim] = token
  }

  func pop_animationDidStop(_ anim: POPSpringAnimation!, finished: Bool) {
    if finished {
      let token = tokens[anim]!
      token.terminate()
      tokens.removeValue(forKey: anim)
    }
  }
}

func coerce(value: Any) -> Any {
  switch value {
  case let rect as CGRect:
    return NSValue(cgRect: rect)
  case let point as CGPoint:
    return NSValue(cgPoint: point)
  default:
    return value
  }
}

extension POPProperty {
  func name() -> String {
    switch self {
    case .layerBackgroundColor: return kPOPLayerBackgroundColor
    case .layerBounds: return kPOPLayerBounds
    case .layerCornerRadius: return kPOPLayerCornerRadius
    case .layerBorderWidth: return kPOPLayerBorderWidth
    case .layerBorderColor: return kPOPLayerBorderColor
    case .layerOpacity: return kPOPLayerOpacity
    case .layerPosition: return kPOPLayerPosition
    case .layerPositionX: return kPOPLayerPositionX
    case .layerPositionY: return kPOPLayerPositionY
    case .layerRotation: return kPOPLayerRotation
    case .layerRotationX: return kPOPLayerRotationX
    case .layerRotationY: return kPOPLayerRotationY
    case .layerScaleX: return kPOPLayerScaleX
    case .layerScaleXY: return kPOPLayerScaleXY
    case .layerScaleY: return kPOPLayerScaleY
    case .layerSize: return kPOPLayerSize
    case .layerSubscaleXY: return kPOPLayerSubscaleXY
    case .layerSubtranslationX: return kPOPLayerSubtranslationX
    case .layerSubtranslationXY: return kPOPLayerSubtranslationXY
    case .layerSubtranslationY: return kPOPLayerSubtranslationY
    case .layerSubtranslationZ: return kPOPLayerSubtranslationZ
    case .layerTranslationX: return kPOPLayerTranslationX
    case .layerTranslationXY: return kPOPLayerTranslationXY
    case .layerTranslationY: return kPOPLayerTranslationY
    case .layerTranslationZ: return kPOPLayerTranslationZ
    case .layerZPosition: return kPOPLayerZPosition
    case .layerShadowColor: return kPOPLayerShadowColor
    case .layerShadowOffset: return kPOPLayerShadowOffset
    case .layerShadowOpacity: return kPOPLayerShadowOpacity
    case .layerShadowRadius: return kPOPLayerShadowRadius
    case .shapeLayerStrokeStart: return kPOPShapeLayerStrokeStart
    case .shapeLayerStrokeEnd: return kPOPShapeLayerStrokeEnd
    case .shapeLayerStrokeColor: return kPOPShapeLayerStrokeColor
    case .shapeLayerFillColor: return kPOPShapeLayerFillColor
    case .shapeLayerLineWidth: return kPOPShapeLayerLineWidth
    case .shapeLayerLineDashPhase: return kPOPShapeLayerLineDashPhase
    case .layoutConstraintConstant: return kPOPLayoutConstraintConstant
    case .viewAlpha: return kPOPViewAlpha
    case .viewBackgroundColor: return kPOPViewBackgroundColor
    case .viewBounds: return kPOPLayerBounds
    case .viewCenter: return kPOPViewCenter
    case .viewFrame: return kPOPViewFrame
    case .viewScaleX: return kPOPViewScaleX
    case .viewScaleXY: return kPOPViewScaleXY
    case .viewScaleY: return kPOPViewScaleY
    case .viewSize: return kPOPLayerSize
    case .viewTintColor: return kPOPViewTintColor
    case .scrollViewContentOffset: return kPOPScrollViewContentOffset
    case .scrollViewContentSize: return kPOPScrollViewContentSize
    case .scrollViewZoomScale: return kPOPScrollViewZoomScale
    case .scrollViewContentInset: return kPOPScrollViewContentInset
    case .scrollViewScrollIndicatorInsets: return kPOPScrollViewScrollIndicatorInsets
    case .navigationBarBarTintColor: return kPOPNavigationBarBarTintColor
    case .labelTextColor: return kPOPLabelTextColor
    }
  }
}
