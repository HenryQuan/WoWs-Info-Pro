import React, { Component } from 'react';
import { TouchableNativeFeedback, TouchableOpacity, Platform, View } from 'react-native';

class WoWsTouchable extends Component {
  render() {
    const { children, ...props  } = this.props;
    const Touchable = (Platform.OS == 'android') ? TouchableNativeFeedback : TouchableOpacity;    
    return (
      <Touchable {...props}>
        <View>
          {children}
        </View>
      </Touchable>
    )
  }
}

export { WoWsTouchable };