use raylib::{ffi::KeyboardKey::*, prelude::*};

trait Coreloops {
    fn update(&mut self, rl: &mut RaylibHandle);
    fn draw(&self, d: &mut RaylibDrawHandle);
}

struct Rocket {
    x: f32,
    y: f32,
    vx: f32,
    vy: f32,
    width: i32,
    height: i32
}

impl Coreloops for Rocket {
    fn update(&mut self, rl: &mut RaylibHandle) {
        let dt = rl.get_frame_time();

        if rl.is_key_down(KEY_UP) {
            self.vy -= 150.0*dt;
        }
        if rl.is_key_down(KEY_LEFT) {
            self.vx -= 100.0*dt;
        }
        if rl.is_key_down(KEY_RIGHT){
            self.vx += 100.0*dt;
        }

        self.x += self.vx;
        self.y += self.vy;

        self.vy += 100.0*dt;
        if self.vx < 0.0 {
            self.vx += (50.0*dt).floor();
        }else{
            self.vx -= (50.0*dt).floor();
        }

        let window_height = rl.get_render_height();
        let window_width = rl.get_render_width();
        if self.y + (self.height as f32) > window_height as f32 {
            self.y = (window_height-self.height) as f32;
            self.vy = 0.0;
            self.vx = 0.0;
        }
        if self.x + (self.width as f32) > window_width as f32 {
            self.x = (window_width-self.width) as f32;
            self.vx = 0.0;
        }
        if self.x < 0.0 {
            self.x = 0.0;
            self.vx = 0.0;
        }
    }

    fn draw(&self, d: &mut RaylibDrawHandle) {
        d.draw_rectangle(self.x as i32, self.y as i32, self.width, self.height, Color::RED);
    }
}

fn main() {
    let (mut rl, thread) = raylib::init()
    .vsync()
    .title("Rocket")
    .size(800, 600)
    .build();

    let window_width = rl.get_render_width();
    let window_height = rl.get_render_height();
    let mut player:Rocket = Rocket { x: (window_width/2) as f32, y: (window_height/2) as f32, vx: 0.0, vy: 0.0, width: 20, height: 40};

    while !rl.window_should_close() {
        player.update(&mut rl);

        let mut d = rl.begin_drawing(&thread);

        d.clear_background(Color::BLACK);
        d.draw_text("Rocket", 0, 0, 12, Color::WHITE);
        
        player.draw(&mut d);
    }
}
