//= require_tree
margin = 4

aspect_ratio = (photo) ->
  photo.width / photo.height

scrollbar_width = () ->
  # Create the measurement node
  scrollDiv = document.createElement "div"
  scrollDiv.className = "scrollbar-measure"
  document.body.appendChild scrollDiv

  # Get the scrollbar width
  scrollbarWidth = scrollDiv.offsetWidth - scrollDiv.clientWidth
  console.warn scrollbarWidth # Mac:  15

  # Delete the DIV 
  document.body.removeChild scrollDiv
  scrollbarWidth

resize_and_add_images = (photos) ->
  img_container = $ "#img-container"
  viewport_width = window.innerWidth - margin - scrollbar_width()
  ideal_height = parseInt (window.innerHeight - margin) / 2
  summed_width = _.reduce photos, ((sum, p) -> sum += aspect_ratio(p) * ideal_height), 0
  rows = Math.ceil summed_width / viewport_width
   
  if rows < 1
    # (2a) Fallback to just standard size 
    photos.each (photo) -> photo.view.resize parseInt(ideal_height * aspect_ratio(photo)), ideal_height
  else
    # (2b) Distribute photos over rows using the aspect ratio as weight
    weights = _.map photos, (p) -> parseInt(aspect_ratio(p) * 100)
    p2 = _.map photos, (p) ->
      ar = aspect_ratio p
      {
        p: p
        ar: ar
        ideal_width: ar * ideal_height
      }
    
    partitions = linear_partition(weights, rows)

    # (3) Iterate through partition
    index = 0
    _.each partitions, (row) ->
      row_buffer = []
      _.each row, -> row_buffer.push(photos[index++])
      summed_ratios = _.reduce row_buffer, ((sum, p) -> sum += aspect_ratio p), 0
      _.each row_buffer, (photo) ->
        div = $ " <div class='img' />"
        div.css {"backgroundImage": 'url("' + photo.src + '")'}
        div.width parseInt(viewport_width / summed_ratios * aspect_ratio photo) - margin
        div.height parseInt(viewport_width / summed_ratios) - margin
        img_container.append div

$().ready ->
  viewer = $ "#img-viewer"
  big_image = $ "#big-image"
  viewer.hide()

  queue = 0
  photos = _.map window.images, (path) ->
    img = new Image()
    img.src = path
    queue++;
    img.onload = () ->
      queue--;
      if queue == 0
        resize_and_add_images photos
    img

  $('#img-container').on 'click', '.img', () ->
    ideal_height = window.innerHeight * .90
    ideal_width = window.innerWidth * .90

    img_to_view = $ this
    if img_to_view.height() > img_to_view.width()
      factor = ideal_height / img_to_view.height()
    else
      factor = ideal_width / img_to_view.width()
    
    img_url = img_to_view.css("backgroundImage").replace('url(','').replace(')','')
    big_image.attr('src', img_url)
    big_image.css {
      "height": img_to_view.height() * factor
      "width": img_to_view.width() * factor
    }

    # colors = RGBaster.colors big_image[0], (payload) ->
    #   # You now have the payload.
    #   console.log(payload.dominant);
    #   console.log(payload.palette);

    $('#background').css('background', img_to_view.css("backgroundImage") + " no-repeat center center")
    viewer.show()
