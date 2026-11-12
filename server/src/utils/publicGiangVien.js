module.exports = (g) => ({
  id: g._id.toString(),
  IDGV: g.IDGV,
  Fullname: g.Fullname,
  Image: g.Image || '',
  SumClass: g.SumClass ?? 0,
});

