// ImageSelectionField.tsx
import React from 'react';
import { MdCloudUpload } from 'react-icons/md';

interface ImageSelectionFieldProps {
  label: string;
  value: string;
  onChange: (e: React.ChangeEvent<HTMLInputElement>) => void;
}

const ImageSelectionField: React.FC<ImageSelectionFieldProps> = ({ label, value, onChange }) => {
  return (
    <div className="mb-4">
      <label htmlFor="image" className="block text-[#8E8E8E] text-xs font-semibold mb-2">
        {label}
      </label>
      <div className="mt-2 flex items-center border rounded-lg px-4 py-2 bg-white shadow-sm focus-within:ring-2 focus-within:ring-blue-500">
        <input
          type="file"
          id="image"
          accept="image/*"
          className="hidden"
          onChange={onChange}
        />
        <span className="text-gray-500 flex-1 cursor-pointer" onClick={() => document.getElementById("image")?.click()}>
          Select Image
        </span>
        <button
          type="button"
          className="text-gray-400 hover:text-gray-500"
          onClick={() => document.getElementById("image")?.click()}
        >
          <MdCloudUpload className="text-xl" />
        </button>
      </div>
    </div>
  );
};

export default ImageSelectionField;
