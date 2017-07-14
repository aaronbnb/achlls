export const createImageRec = image => (
  $.ajax({
    method: 'POST',
    url: `https://vision.googleapis.com/v1/images:annotate`,
    data: { image }
  })
);
