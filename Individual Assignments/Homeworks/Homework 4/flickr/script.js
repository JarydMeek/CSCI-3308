//counter for when we reach the bottom of the page
let page = 1;

function clearPage() {
    document.getElementById("mainBody").innerHTML = '';
}
//Add more images if we hit the bottom of page
window.onscroll = function() {
    if ((window.innerHeight + window.scrollY) >= document.body.offsetHeight) {
      page++;
      makeApiCall();
    }
  };

function makeApiCall() {
    //First things first, lets grab the two inputs and store them
    let numberOfPhotos = document.getElementById("numberOfPhotos").value
    let filter = document.getElementById("filter").value;
    let currentImages = document.getElementById("mainBody").innerHTML;
    
    
    
    //Ok, Now we can make an AJAX call to get the data we need
    let url = 'https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=963dcd8c9b61b5b77543ecc1592c315a&tags=' + filter + '&per_page=' + numberOfPhotos + '&page=' + page +  '&format=json&nojsoncallback=1';
    $.ajax({url:url, dataType:"json"}).then(function(data) {
        console.log(data);
        //array of pictures
        let pictures = data.photos.photo;
        //add the pictures to the webpage
        var populate = currentImages;
        pictures.forEach(picture => {
            let serverId = picture.server;
            let id = picture.id;
            let secret = picture.secret;
            let title = picture.title;
            populate += '<div style="width: 25%; padding:15px;">\n<div class="card">\n<div class="card-body">\n<img src="https://live.staticflickr.com/' + serverId + '/' + id + '_' + secret + '_q.jpg" width="100%" height="auto">\n<h5 class="card-title">' + title + '</h5>\n</div>\n</div>\n</div>\n';
        });
        document.getElementById("mainBody").innerHTML = populate;
    })
    
    
}