import React from 'react';

interface InputFieldProps {
  label: string;
  type: string;
  value: string | number;
  onChange: (e: React.ChangeEvent<HTMLInputElement>) => void;
  placeholder?: string;
}

const InputField: React.FC<InputFieldProps> = ({ label, type, value, onChange , placeholder }) => {
  return (
    <div className="mb-4">
      <label className="block text-[#8E8E8E] text-xs font-semibold mb-2">{label}</label>
      <input
        type={type}
        value={value}
        onChange={onChange}
        placeholder={placeholder} // Pass placeholder to input
        className="w-full h-10 lg:h-12 lg:text-[18px] px-5 border border-[#282828] rounded-[14px] focus:outline-none focus:ring-1 focus:ring-[#1175BC] focus:border-transparent"
      />
    </div>
  );
};

export default InputField;
