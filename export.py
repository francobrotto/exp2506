from google.cloud import firestore
import pandas as pd

def flatten_dict(d, parent_key='', sep='.'):
    """Recursively flattens nested dictionaries and lists of dictionaries"""
    items = []
    for k, v in d.items():
        new_key = f"{parent_key}{sep}{k}" if parent_key else k
        if isinstance(v, dict):
            items.extend(flatten_dict(v, new_key, sep=sep).items())
        elif isinstance(v, list):
            for i, item in enumerate(v):
                if isinstance(item, dict):
                    # Flatten each dict in the list
                    items.extend(flatten_dict(item, f"{new_key}{sep}{i}", sep=sep).items())
                else:
                    # Handle lists of primitives
                    items.append((f"{new_key}{sep}{i}", item))
        else:
            items.append((new_key, v))
    return dict(items)

def export_firestore_to_csv(collection_name, output_csv):
    db = firestore.Client()
    docs = db.collection(collection_name).stream()

    data = []
    for doc in docs:
        doc_dict = doc.to_dict()
        doc_dict['id'] = doc.id
        flat_doc = flatten_dict(doc_dict)
        data.append(flat_doc)

    if not data:
        print("No data found in collection:", collection_name)
        return

    df = pd.DataFrame(data)
    df.to_csv(output_csv, index=False)
    print(f"Exported {len(data)} documents to {output_csv}")

if __name__ == "__main__":
    collection = "version1-0"  # Firestore collection name
    output_file = "firestore_export_flat.csv"
    export_firestore_to_csv(collection, output_file)
