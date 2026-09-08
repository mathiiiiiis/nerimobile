enum NeriBorderRole { hairline, thin, medium, thick }

const neriBorderDefaults = <NeriBorderRole, double>{
  NeriBorderRole.hairline: 1,
  NeriBorderRole.thin: 1.5,
  NeriBorderRole.medium: 2.5,
  NeriBorderRole.thick: 4,
};

const neriBorderScaleRange = (min: 0.5, max: 3.0);
