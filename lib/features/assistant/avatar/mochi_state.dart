
/// Active operational state of the Mochi character.
enum MochiState {
  /// Natural idle breathing, random blinks.
  idle,

  /// Active processing, animated dots badge, blue glow.
  working,

  /// Thinking, gaze directed up-right (+0.55, +0.55), purple tint.
  thinking,

  /// Searching knowledge, eyes scan rhythmically, indigo tint.
  searching,

  /// Awaiting confirmation / approval, eager bounce, exclamation badge.
  approval,

  /// Inquisitive, head tilt, question badge.
  question,

  /// Error state, horizontal head shake, red dot badge.
  error,

  /// Task completed, celebratory 360° roll, sparks, green badge.
  finished,

  /// Rate limit reached, tired expression, sweat drops.
  ratelimit,

  /// Resting / idle timeout, closed eyes, floating Zzz.
  sleeping,

  /// Dizzy / multiple rapid taps, double barrel roll, spiral eyes.
  dizzy,

  /// Empathetic / sensitive mode, calm posture, no shaking.
  gentle;
}

/// Transient emotional overlays that temporarily modify eye shape or facial expression.
enum MochiEmote {
  love,
  surprised,
  proud,
  wink,
  yawn,
  happy,
  annoyed,
}

/// Shape of the eyes drawn on the 3D projection plane.
enum EyeShape {
  pill,
  wide,
  dot,
  line,
  flat,
  happy,
  closed,
  spiral,
  heart,
  star,
  tired,
  wink,
}

/// Overhead badge indicator.
enum BadgeType {
  none,
  dots,
  bang,
  question,
  dot,
}

/// Type of floating atmospheric particle.
enum ParticleType {
  heart,
  star,
  spark,
  sweat,
  z,
}

/// Particle model rendered around the character.
class MochiParticle {
  MochiParticle({
    required this.type,
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.life,
    this.age = 0.0,
    this.rot = 0.0,
    this.sz = 0.2,
  });

  final ParticleType type;
  double x;
  double y;
  double vx;
  double vy;
  double life;
  double age;
  double rot;
  double sz;
}
