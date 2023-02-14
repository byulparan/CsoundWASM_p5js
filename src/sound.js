import {Csound} from "@csound/browser";
import * as dat from 'dat.gui';
import csoundCode from './sound.csd?raw';

// ================================================================================
// Controller
// ================================================================================

export const guiControl = {
  boot : startCsound,
  run : false,
  bpm: 140,
  count: 27,
  boxColor: "#ffb5cd",
  textColor: "#fff"
};

let gui = new dat.GUI();
gui.add(guiControl, 'boot').name('Boot Csound');
gui.add(guiControl, 'run').name('Start/Stop Csound').onChange(runCsound);
gui.add(guiControl, 'bpm', 30, 180).name('BPM').step(1).onChange((v) => {
  if(csound) {
    csound.setControlChannel("gkBPM", Math.floor(v));
  }
});
gui.add(guiControl, 'count', 1, 32).name('count').step(1).onChange((v) => {
  if(csound) {
    csound.setControlChannel("gkLimit", Math.floor(v));
  }
});
gui.addColor(guiControl, 'boxColor');
gui.addColor(guiControl, 'textColor');


// ================================================================================
// Csound
// ================================================================================

export let csound;
export let csoundLogs = [];
const MAX_LOG = 50;

async function startCsound() {
  if(!csound) {
    let csnd = await Csound();
    await csnd.on('message', insertLog);
    await csnd.compileCsdText(csoundCode);
    await csnd.start();
    csound = csnd;
  }
}

function runCsound(flag) {
  if(csound) {
    csound.setControlChannel("gkRunning", flag ? 1 :  0);
  }
}

const insertLog = (text) => {
  if (csoundLogs.length >= MAX_LOG) {
    csoundLogs = csoundLogs.slice(1, MAX_LOG);
  }
  csoundLogs.push(text);
};
