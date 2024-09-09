// JavaScript function for retrieving accurate GPS location (12 decimal places)
function getAccurateLocation() {
  if (navigator.geolocation) {
    navigator.geolocation.getCurrentPosition(onSuccess, onError, {
      enableHighAccuracy: true,
      maximumAge: 0,
      timeout: 5000
    });
  } else {
    console.error("Geolocation is not supported by this browser.");
  }

  function onSuccess(position) {
    // Extract latitude and longitude to 12 decimal places
    const latitude = position.coords.latitude.toFixed(12);
    const longitude = position.coords.longitude.toFixed(12);

    // Send the latitude and longitude back to Shiny (or any server-side process)
    Shiny.onInputChange('geolocation', {
      lat: latitude,
      long: longitude,
      time: new Date().toISOString() // Send the timestamp as well
    });

    // Optionally, log the coordinates for debugging purposes
    console.log("Latitude: " + latitude + ", Longitude: " + longitude);
  }

  function onError(error) {
    // Handle any errors in obtaining the location
    console.error("Error obtaining location: " + error.message);
    Shiny.onInputChange('geolocation', { error: error.message });
  }
}
