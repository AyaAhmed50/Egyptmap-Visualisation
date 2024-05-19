PImage mapImage;//Contain Egypt map
Table locationTable;//Contain City location
Table population;//Contain population, city, Density, Area
int rowCount;//Row count for location Table.
float dataMin = MAX_FLOAT;
float dataMax = MIN_FLOAT;
String clickedInfo = "";
int startTime = 0;
/// size of ellipse depends on population 
//Color of ellipse depends on density to show how crowded the city is!!


void setup( ) {
  size(1200, 900);
  mapImage = loadImage("Map1.png");
  locationTable = loadTable("location2.csv","header");
  population = loadTable("random2.csv", "header");
  
  rowCount = locationTable.getRowCount( );
  mapImage.resize(1200, 900);
  image(mapImage, 0, 0);
  
  ////////////Start Parsing
  println("before parsing to float: "+population.getFloat(0,"population"));
  castStringToNumeric("population");
  println("After parsing to float: "+population.getFloat(0,"population"));
  castStringToNumeric("Density");
  println("After parsing to float: "+population.getFloat(5,"Density"));
  castStringToNumeric("Area");
  println("After parsing to float: "+population.getFloat(5,"Area"));
  ////////////End Parsing.
  print("Aswan"+" "+population.getFloat(findRowByColumnValue(population,"City","Aswan"), 1));
  for (int row = 0; row < rowCount; row++) {//to be used later in map function.
    float value = population.getFloat(row, 1);
    if (value > dataMax) {
      dataMax = value;
      }
    if (value < dataMin) {
      dataMin = value;
      }
    }
  
}

///parsing function.
void castStringToNumeric(String columnName) {
  // Iterate over each row in the table
  for (TableRow row : population.rows()) {
    // Get the string value from the specified column
    String stringValue = row.getString(columnName);
    
    // Remove commas from the string value
    stringValue = stringValue.replaceAll(",", "");
    
    // Check if the string value is not empty
    if (!stringValue.isEmpty()) {
      // Try to parse the string value to a numeric type
      try {
        float numericValue = Float.parseFloat(stringValue);
        // Store the numeric value back into the column
        row.setFloat(columnName, numericValue);
      } catch (NumberFormatException e) {
        // Handle parsing errors (e.g., if the string is not a valid number)
        println("Error parsing value: " + stringValue);
      }
    }
  }
}
int findRowByColumnValue(Table Data, String columnName, String desiredValue) {
  // Iterate over each row in the table
  for (int i = 0; i < locationTable.getRowCount(); i++) {
    // Get the value from the specified column in the current row
    String columnValue = Data.getString(i, columnName);
    
    // Check if the value matches the desired value
    if (columnValue.equals(desiredValue)) {
      return i; // Return the index of the row with the desired value
    }
  }
  
  // Return -1 if the desired value is not found in the specified column
  return -1;
}

float[] findColumnMinMax(Table table, String columnToCheck) {
  float[] columnValues = new float[table.getRowCount()];

  // Extract column values into an array
  for (int i = 0; i < table.getRowCount(); i++) {
    columnValues[i] = table.getFloat(i, columnToCheck);
  }

  // Find minimum and maximum using min() and max() functions
  float minValue = min(columnValues);
  float maxValue = max(columnValues);

  // Create an array to hold min and max values
  float[] result = { minValue, maxValue };
  return result;
}


void draw( ) {
  background(255);
  image(mapImage, 0, 0);
  // Drawing attributes for the ellipses.
  mapImage.resize(1200,900);
  image(mapImage, 0 ,0);
  //mapImage.resize()
  smooth( );
  fill(192, 0, 0);
  noStroke( );
  // Loop through the rows of the locations file //and draw the points.
  for (int row = 0; row < rowCount; row++) {
    String abbrev = population.getString(row,0);
    float x = locationTable.getFloat(findRowByColumnValue(locationTable,"City",abbrev), 1);
    float y = locationTable.getFloat(findRowByColumnValue(locationTable,"City",abbrev), 2);
    drawData(x, y, abbrev);
    }
    
  if (millis() - startTime < 3000) {
    // Draw the rectangle at the mouse position with width=150 and height=70
    fill(0); // Set rectangle fill color to gray
    rect(mouseX, mouseY, 200, 100);
    
    // Display information about the clicked point inside the rectangle
    
    fill(255); // Set text color to black
    textAlign(LEFT, TOP);
    textSize(20);
    text(clickedInfo, mouseX + 10, mouseY + 10);
  }
}

void mouseClicked() {
  // Get information about the clicked point
  String[] data = getData(mouseX, mouseY);
  
  // Set clickedInfo using the retrieved data
  clickedInfo = "City: " + data[0] + "\nPopulation: " + data[1] + "\nDensity: " + data[2] + "\nArea: " + data[3];
  
  // Store the current time
  startTime = millis();
}
String[] getData(int x_map, int y_map){
  //City, population, Density, Area
  String[] info = new String[4];
  for( int row =0; row < rowCount; row++){
    float x = locationTable.getFloat(row, 1);
    float y = locationTable.getFloat(row, 2);
    if ((x >= x_map - 8 && x <= x_map + 8) && (y >= y_map - 8 && y <= y_map + 8)) {
      info[0] = locationTable.getString(row,"City");
      info[1] = str(population.getFloat(findRowByColumnValue(population,"City",info[0]),"population"));
      info[2] = str(population.getFloat(findRowByColumnValue(population,"City",info[0]),"Density"));
      info[3] = str(population.getFloat(findRowByColumnValue(population,"City",info[0]),"Area"));
      println(info[0]);
    }
  }
  return info;
}
void drawData(float x, float y, String abbrev) {
  
    //for the population increase ellipse.
    // Get data value for state
    float value_population = population.getFloat(findRowByColumnValue(population,"City",abbrev), 1);
    
    //println("population"+population.getFloat(findRowByColumnValue("City",abbrev), 1));
    // Re-map the value to a number between 2 and 40
    float mapped = map(value_population, dataMin, dataMax, 10, 45);
    // Draw an ellipse for this item
    
    
    //For Density of population.
    float value_Density = population.getFloat(findRowByColumnValue(population,"City",abbrev), "Density");
    float[] result = findColumnMinMax(population,"Density");
    float percent = norm(value_Density, result[0], result[1]);
    color between = lerpColor( #18BB05, #BB2505, percent); // Green to red.
    fill(between);
    ellipse(x, y, mapped, mapped);
}
