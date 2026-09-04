enum NeriRadiusRole { sm, image, md, lg, xl, full }

const neriRadiusDefaults = <NeriRadiusRole, double>{
  NeriRadiusRole.sm: 4,
  NeriRadiusRole.image: 8,
  NeriRadiusRole.md: 10,
  NeriRadiusRole.lg: 12,
  NeriRadiusRole.xl: 15,
  NeriRadiusRole.full: 999,
};

const neriRadiusScaleRange = (min: 0.0, max: 2.0);
