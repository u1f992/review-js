declare global {
  var Opal: OpalStatic;
}
export interface OpalClass<T> {
  $new(...args: unknown[]): T;
  [key: string]: unknown;
}
export interface OpalStatic {
  hash(obj?: Record<string, unknown>): unknown;
  nil: unknown;
  [key: string]: unknown;
}

export interface CompileOptions {
  chapter_number?: number;
  chapter_name?: string;
  config?: ReviewConfig;
}

export interface ReviewConfig {
  language?: string;
  htmlversion?: number;
  secnolevel?: number;
  table_row_separator?: 'tabs' | 'singletab' | 'spaces' | 'verticalbar';
  caption_position?: {
    list?: 'top' | 'bottom';
    image?: 'top' | 'bottom';
    table?: 'top' | 'bottom';
    equation?: 'top' | 'bottom';
  };
  draft?: boolean;
  externallink?: boolean;
  chapterlink?: boolean;
  htmlext?: string;
}

export type OutputFormat = 'html' | 'markdown' | 'md' | 'latex' | 'tex';

export interface API {
  $compile(source: string, format?: OutputFormat, options?: any): string;
  $parse(source: string): { source: string };
  $available_formats(): string[];
  $version(): string;
}

export interface I18n {
  $t(key: string, args?: any): string;
  $setup(locale: string, ymlfile?: string | null): void;
}

export interface BookModule {
  VirtualBook: any;
  VirtualChapter: any;
  VirtualConfig: any;
}

export declare class Builder {
  constructor();
  static $new(): Builder;
}

export declare class HTMLBuilder extends Builder {
  constructor();
  static $new(): HTMLBuilder;
}

export declare class MARKDOWNBuilder extends Builder {
  constructor();
  static $new(): MARKDOWNBuilder;
}

export declare class LATEXBuilder extends Builder {
  constructor();
  static $new(): LATEXBuilder;
}

export declare class Compiler {
  constructor(builder: Builder);
  static $new(builder: Builder): Compiler;
}

/**
 * Virtual FileSystem API for in-memory file operations
 */
export interface VirtualFileSystem {
  /**
   * Add a file to the virtual filesystem
   * @param path - File path (e.g., '/content/chapter1.re')
   * @param content - File content
   */
  writeFile(path: string, content: string): void;

  /**
   * Read a file from the virtual filesystem
   * @param path - File path
   * @returns File content
   */
  readFile(path: string): string;

  /**
   * Check if a file exists
   * @param path - File path
   * @returns true if file exists
   */
  exists(path: string): boolean;

  /**
   * Delete a file
   * @param path - File path
   */
  deleteFile(path: string): void;

  /**
   * Create a directory
   * @param path - Directory path
   * @param recursive - Create parent directories if needed
   */
  mkdir(path: string, recursive?: boolean): void;

  /**
   * List files in a directory
   * @param path - Directory path
   * @returns Array of file names
   */
  listFiles(path: string): string[];

  /**
   * Load multiple files from a JSON object
   * @param files - Object with path keys and content values
   */
  fromJSON(files: Record<string, string>): void;

  /**
   * Export all files to a JSON object
   * @returns Object with path keys and content values
   */
  toJSON(): Record<string, string>;

  /**
   * Clear all files
   */
  reset(): void;
}

export interface ReVIEWModule {
  API: API;
  I18n: I18n;
  Book: BookModule;
  Compiler: typeof Compiler;
  Builder: typeof Builder;
  HTMLBuilder: typeof HTMLBuilder;
  MARKDOWNBuilder: typeof MARKDOWNBuilder;
  LATEXBuilder: typeof LATEXBuilder;
  vfs: VirtualFileSystem;
  [key: string]: unknown;
}

/**
 * Virtual FileSystem instance
 */
export declare const vfs: VirtualFileSystem;

/**
 * VirtualFileSystem class constructor
 */
export declare class VirtualFileSystem {
  constructor();
}

declare const ReVIEW: ReVIEWModule;
export default ReVIEW;
