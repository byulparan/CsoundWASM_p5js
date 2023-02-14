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
     canvas.background(0, 40);

     pg.clear();
     pg.perspective(45.0, p5.width/ p5.height, .01, 100.0);
     pg.camera(10.0, -10.0, 10.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0);

     pg.noFill();
     pg.strokeWeight(2.);
     pg.stroke(guiControl.boxColor);

     pg.rotateX(p5.cos(0.4*time) * p5.TAU);
     pg.rotateY(p5.cos(0.4*time) * p5.TAU);
     pg.rotateZ(p5.cos(0.4*time) * p5.TAU);
     // pg.rotateY(TAU*.25);

     let size = csoundChannel.mix * 10;

     pg.sphere(size);

     for(let i = 1; i < csoundChannel.mix * 4; i++) {
       pg.box(size + i*size);
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
