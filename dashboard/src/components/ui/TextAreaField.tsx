import React from "react";

interface TextAreaFieldProps {
  label: string;
  value: string;
  onChange: (e: React.ChangeEvent<HTMLTextAreaElement>) => void;
  placeholder?: string;
  rows?: number;
}

const TextAreaField: React.FC<TextAreaFieldProps> = ({
  label,
  value,
  onChange,
  placeholder,
  rows = 4, // Default to 4 rows if not provided
}) => {
  return (
    <div className="mb-4">
      <label className="block text-[#8E8E8E] text-xs font-semibold mb-2">{label}</label>
      <textarea
        value={value}
        onChange={onChange}
        placeholder={placeholder}
        rows={rows}
        className="w-full lg:text-[18px] p-4 border border-[#282828] rounded-[14px] focus:outline-none focus:ring-1 focus:ring-[#1175BC] focus:border-transparent"
      />
    </div>
  );
};

export default TextAreaField;
