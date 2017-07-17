let images = document.getElementsByTagName('img');





for (let i = 0; i < images.length; i++) {
  if (images[i].alt !== null || images[i].alt !== 'undefined') {
    images[i].alt = "hello!";
  }
}
