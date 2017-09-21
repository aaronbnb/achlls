# Achlls

This in-development Chrome extension generates alternative text attributes for images on a webpage,
making the site more accessible to the visually impaired that rely on screen
readers such as JAWS. We hope to grow this project into a sustainable business that helps make the
Internet accessible. Our goal is to create a product which can 'overlay' accessibility on a completed site rather than have to integrate accessibility at its ground floor, which is a challenge for developers.
Please check out our [pitch deck](https://docs.google.com/presentation/d/1-NNViQdq4lbtc3Hd14aycO45S8lDwwa2zBHbB80R30s/edit?usp=sharing)

The program uses Ruby's Nokogiri gem to parse the HTML, grabbing the
images on the webpages. The images are then encoded base-64 and uploaded to
Google Cloud Vision API, avoiding having to open the image twice.
Google doesn't have to open the images again. The program first use Cloud Vision to
broadly categorize the image. The program then determines a more targeted search such as landmark detection or
web detection, which searches for similar images. If the image contains text, a common issue in non-semantic HTML,
Achlls activates optical character recognition.

The program then derives meaningful text about the image and assigns the description to the image's alternative
text attribute. If the image already has an alternative text attribute, the program parses the text and manipulates into form better read by screen readers. The new image description generated by the program is appended to the end of the original alternative text.

## Future Features

This program could use some logic to correct other similar issues around images such as the description being put into a `<figcaption>` which is not accessible to screen readers.
