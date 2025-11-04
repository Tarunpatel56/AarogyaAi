import pandas as pd
import sqlite3
import os

# --- Configuration ---
cleaned_csv = 'Cleaned_Medicine_Database(in).csv' # The file you just edited
database_file = 'medicines.db'
table_name = 'medicines'
# -------------------

print(f"Loading your completed file: {cleaned_csv}...")

try:
    df = pd.read_csv(cleaned_csv)

    # Safety check: If any dosage info is still empty, fill it with a warning.
    if df['dosage_info'].isnull().any() or (df['dosage_info'] == "").any():
        print("\nWARNING: Some 'dosage_info' fields are still empty.")
        print("The app will add a warning for these medicines.")
        df['dosage_info'].fillna("Dosage not available. Please consult a doctor.", inplace=True)
        df['dosage_info'].replace("", "Dosage not available. Please consult a doctor.", inplace=True)

    # Delete old database file if it exists
    if os.path.exists(database_file):
        os.remove(database_file)
        print(f"Removed old '{database_file}'.")

    # Connect to (and create) the new SQLite database
    conn = sqlite3.connect(database_file)

    # Save the data to the 'medicines' table
    df.to_sql(table_name, conn, if_exists='replace', index=False)

    print(f"SUCCESS! Created the final app database: '{database_file}'.")
    print("You can now copy this file to your Flutter project.")
    conn.close()

except FileNotFoundError:
    print(f"ERROR: Could not find '{cleaned_csv}'. Make sure it's in the same folder.")
except Exception as e:
    print(f"An error occurred: {e}")