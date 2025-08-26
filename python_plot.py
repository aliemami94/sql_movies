import pandas as pd
import matplotlib.pyplot as plt

def plot_rental_figures_by_year(file_path):
    """
    Reads rental data from a CSV file and generates separate bar charts for
    each year (2005 and 2006), saving them as PNG files.

    Args:
        file_path (str): The path to the CSV file containing the data.
    """
    try:
        # Load the CSV data into a pandas DataFrame
        df = pd.read_csv(file_path)

        # Loop through the years to create a separate plot for each
        for year in [2005, 2006]:
            # Filter the DataFrame for the current year
            df_year = df[df['rental_year'] == year]

            # Create a new figure and axes for the plot
            plt.figure(figsize=(12, 7))

            # Create the bar chart for the single year
            plt.bar(df_year['category_name'], df_year['number_of_rentals'], color='skyblue')

            # Add titles and labels for clarity
            plt.title(f'Number of Film Rentals by Category in {year}', fontsize=16)
            plt.xlabel('Film Category', fontsize=12)
            plt.ylabel('Number of Rentals', fontsize=12)
            plt.xticks(rotation=45, ha='right') # Rotate x-axis labels for better readability
            plt.grid(axis='y', linestyle='--', alpha=0.7)
            plt.tight_layout() # Adjust layout to prevent labels from being cut off

            # Define the output file name and save the figure
            output_file = f'rentals_{year}.png'
            plt.savefig(output_file)
            print(f"Chart for {year} successfully saved to {output_file}")

    except FileNotFoundError:
        print(f"Error: The file '{file_path}' was not found.")
    except Exception as e:
        print(f"An error occurred: {e}")

# Call the function with your CSV file name
plot_rental_figures_by_year('per_year.csv')
