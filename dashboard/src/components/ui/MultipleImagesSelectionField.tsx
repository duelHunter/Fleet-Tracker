// MultipleImagesSelectionField.tsx
import Image from "next/image";
import React from "react";
import { MdCloudUpload, MdDelete } from "react-icons/md";

interface MultipleImagesSelectionFieldProps {
  label: string;
  values: string[];
  onChange: (images: string[]) => void;
  uniqueId: string; // Add a unique ID for each instance
}

const MultipleImagesSelectionField: React.FC<MultipleImagesSelectionFieldProps> = ({
  label,
  values,
  onChange,
  uniqueId,
}) => {
  const handleFileChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    if (event.target.files) {
      const filesArray = Array.from(event.target.files);
      const readers = filesArray.map((file) => {
        const reader = new FileReader();
        return new Promise<string>((resolve) => {
          reader.onload = () => resolve(reader.result as string);
          reader.readAsDataURL(file);
        });
      });

      Promise.all(readers).then((images) => {
        onChange([...values, ...images]); // Append new images
      });
    }
  };

  const handleRemoveImage = (index: number) => {
    const updatedValues = values.filter((_, i) => i !== index); // Remove image at index
    onChange(updatedValues);
  };

  return (
    <div className="mb-4">
      <label htmlFor={`images-${uniqueId}`} className="block text-[#8E8E8E] text-xs font-semibold mb-2">
        {label}
      </label>
      <div className="mt-2 border rounded-lg p-4 bg-white shadow-sm">
        <div className="flex items-center space-x-2">
          <input
            type="file"
            id={`images-${uniqueId}`} // Use unique ID here
            accept="image/*"
            multiple
            className="hidden"
            onChange={handleFileChange}
          />
          <button
            type="button"
            className="flex items-center text-gray-500 hover:text-gray-700 cursor-pointer"
            onClick={() => document.getElementById(`images-${uniqueId}`)?.click()}
          >
            <MdCloudUpload className="text-xl mr-2" /> Upload Images
          </button>
        </div>
        <div className="mt-4 grid grid-cols-2 md:grid-cols-4 gap-4">
          {values.map((image, index) => (
            <div key={index} className="relative">
              <img
                src={image}
                alt={`Selected ${index + 1}`}
                className="w-full h-32 object-cover rounded-lg"
              />
              <button
                type="button"
                className="absolute top-2 right-2 bg-red-500 text-white rounded-full p-1 hover:bg-red-700"
                onClick={() => handleRemoveImage(index)}
              >
                <MdDelete className="text-sm" />
              </button>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

export default MultipleImagesSelectionField;
