import React, { PureComponent } from 'react';
import { WebView, Linking } from 'react-native';
import language from '../../constant/language';

export default class Browser extends PureComponent {
  constructor(props) {
    super(props);
    this.props.navigator.setOnNavigatorEvent(this.onNavigatorEvent.bind(this));
  }

  static navigatorStyle = {
    tabBarHidden: true
  }

  static navigatorButtons = {
    rightButtons: [{ title: language.open_in_browser_title, id: 'broswer' }]
  };

  onNavigatorEvent(event) {
    if (event.type == 'NavBarButtonPress') {
      if (event.id == 'broswer') {
        Linking.openURL(this.props.link);
      }
    }
  }

  render() {
    return (
      <WebView source={{uri: this.props.link}}/>
    )
  }
}