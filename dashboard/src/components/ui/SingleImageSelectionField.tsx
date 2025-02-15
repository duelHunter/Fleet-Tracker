// SingleImageSelectionField.tsx
import Image from "next/image";
import React from "react";
import { MdCloudUpload, MdDelete } from "react-icons/md";

interface SingleImageSelectionFieldProps {
  label: string;
  value: string | null;
  onChange: (image: string | null) => void;
  uniqueId: string; // Add a unique ID for each instance
}

const SingleImageSelectionField: React.FC<SingleImageSelectionFieldProps> = ({
  label,
  value,
  onChange,
  uniqueId,
}) => {
  const handleFileChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    if (event.target.files && event.target.files[0]) {
      const file = event.target.files[0];
      const reader = new FileReader();
      reader.onload = () => onChange(reader.result as string);
      reader.readAsDataURL(file);
    }
  };

  const handleRemoveImage = () => {
    onChange(null); // Remove image by setting value to null
  };

  return (
    <div className="mb-4">
      <label htmlFor={`image-${uniqueId}`} className="block text-[#8E8E8E] text-xs font-semibold mb-2">
        {label}
      </label>
      <div className="mt-2 border rounded-lg p-4 bg-white shadow-sm">
        <div className="flex items-center space-x-2">
          <input
            type="file"
            id={`image-${uniqueId}`} // Use unique ID here
            accept="image/*"
            className="hidden"
            onChange={handleFileChange}
          />
          <button
            type="button"
            className="flex items-center text-gray-500 hover:text-gray-700 cursor-pointer"
            onClick={() => document.getElementById(`image-${uniqueId}`)?.click()}
          >
            <MdCloudUpload className="text-xl mr-2" /> Upload Image
          </button>
        </div>
        {value && (
          <div className="mt-4 relative inline-block">
            <img
              src={value}
              alt="Selected"
              className="h-32 object-cover rounded-lg"
            />
            <button
              type="button"
              className="absolute top-2 right-2 bg-red-500 text-white rounded-full p-1 hover:bg-red-700"
              onClick={handleRemoveImage}
            >
              <MdDelete className="text-sm" />
            </button>
          </div>
        )}
      </div>
    </div>
  );
};

export default SingleImageSelectionField;
