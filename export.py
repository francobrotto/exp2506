from google.cloud import firestore
import json
from google.protobuf.timestamp_pb2 import Timestamp
from google.cloud.firestore_v1 import _helpers

def convert_firestore_types(obj):
    """
    Recursively convert Firestore-specific types (like timestamps)
    into JSON-serializable Python types (strings).
    """
    if isinstance(obj, dict):
        return {k: convert_firestore_types(v) for k, v in obj.items()}
    elif isinstance(obj, list):
        return [convert_firestore_types(i) for i in obj]
    elif isinstance(obj, Timestamp):
        return obj.ToDatetime().isoformat()
    elif isinstance(obj, _helpers.DatetimeWithNanoseconds):
        # Convert Firestore DatetimeWithNanoseconds to ISO string
        return obj.isoformat()
    elif hasattr(obj, "ToDatetime"):  # fallback for other datetime-like objects
        return obj.ToDatetime().isoformat()
    else:
        return obj

def export_firestore_to_json(collection_name, output_json):
    db = firestore.Client()
    docs = db.collection(collection_name).stream()

    data = []
    for doc in docs:
        doc_dict = doc.to_dict()
        doc_dict["session_id"] = doc.id
        clean_doc = convert_firestore_types(doc_dict)
        data.append(clean_doc)

    with open(output_json, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print(f"Exported {len(data)} participants to {output_json}")

if __name__ == "__main__":
    collection = "preManipulation-0"
    output_file = "firestore_export.json"
    export_firestore_to_json(collection, output_file)
