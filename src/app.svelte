<script>
 import P5 from 'p5-svelte';
 import { csound, csoundLogs, guiControl } from './sound.js';

 
 let csoundChannel = {
   mix: 0.0,
   kickMix: 0.0
 };
 
 let canvas;
 let pg;

 let sketch = (p5) => {
   p5.setup = () => {
     p5.pixelDensity(1.0);
     p5.createCanvas(p5.windowWidth, p5.windowHeight);
     let w = p5.width;
     let h = p5.height;
     canvas = p5.createGraphics(w, h);
     pg = p5.createGraphics(w, h, p5.WEBGL);
     pg.setAttributes('alpha', true);
     p5.background(0);
   }

   p5.draw = () => {
     let time = p5.millis() * 0.001;

     p5.background(0);
     canvas.background(0, 30);

     pg.clear();
     pg.perspective(45.0, p5.width/ p5.height, .01, 100.0);
     pg.camera(0.0, 0.0, 10, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0);

     
     pg.rotateX(p5.cos(0.4*time) * p5.TAU);
     pg.rotateY(p5.cos(0.4*time) * p5.TAU);
     pg.rotateZ(p5.cos(0.4*time) * p5.TAU);

     let size = csoundChannel.mix * 2;

     
     pg.strokeWeight(3.);

     for(let i = 1; i < csoundChannel.mix * guiControl.boxRepeat; i++) {
       pg.push();
       pg.rotateX(size*i);
       pg.fill(100, i * 50, 100.0, csoundChannel.kickMix*2000);
       pg.stroke(100, i * 50, 100.0);
       pg.box(size * i * 2);
       pg.pop();
     }
     
     canvas.image(pg, 0, 0, pg.width, pg.height);
     p5.image(canvas, 0, 0, p5.width, p5.height);


     p5.fill(guiControl.textColor);
     p5.textSize(12.0);
     for(let i = 0; i < csoundLogs.length; i++) {
       p5.text(csoundLogs[i], 10, 30 + 14 * i);
     }
     
     
     if (csound) {
       csound.getControlChannel('gkMix').then((v) => csoundChannel.mix = v);
       csound.getControlChannel('gkKickMix').then((v) => csoundChannel.kickMix = v);
     }
   }
 }

</script>


<P5 {sketch} />
