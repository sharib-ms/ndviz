import React from 'react';
import ReactDOM from 'react-dom';

import Visualizer from './visualizer.jsx';

import State from './state.js';
import ToolboxMenu from './toolbox/toolbox.jsx';

class NDViz extends React.Component {
  constructor(props) {
    super(props);

    // register functions
    this.triggerRender = this.triggerRender.bind(this);

    // read initial state from the window
    if (window.config) {
          this.stateObject = new State(window.config.xstart, window.config.xoffset, window.config.xsize, window.config.ystart, window.config.yoffset, window.config.ysize, window.config.zstart, window.config.zoffset, window.config.zsize, window.config.minres, window.config.maxres, window.config.res);
    }

  }
  triggerRender() {
    this.refs.mainVisualizer.triggerRender();
  }
  componentDidMount() {
    this.triggerRender();
  }
  render() {
    return (
      <div>
        <Visualizer
          ref="mainVisualizer"
          viewerState={this.stateObject}
        />
        <div style={{position: "absolute", top: 50, right: 0, paddingRight: 10, paddingTop: 5}}>
          <ToolboxMenu />
        </div>
      </div>
    );
  }
}

ReactDOM.render(
    <NDViz />,
    document.getElementById('react-target')
);